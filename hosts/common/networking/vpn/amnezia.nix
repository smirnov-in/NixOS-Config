{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.duck.vpn.amnezia;

  enabledInstances = lib.filterAttrs (_: instance: instance.enable) cfg.instances;

  mkInterfaceSuffix = name: builtins.substring 0 8 (builtins.hashString "sha256" name);
  mkHostInterface = name: "vpn-${mkInterfaceSuffix name}-h";
  mkNamespaceInterface = name: "vpn-${mkInterfaceSuffix name}-n";
  mkResolvConf = name: "/etc/netns/${name}/resolv.conf";
  mkRuntimeConfig = name: "/run/duck-vpn/amnezia/${name}.conf";

  mkNameserverArgs =
    dnsServers: lib.concatMapStringsSep " " (dns: lib.escapeShellArg "nameserver ${dns}") dnsServers;

  mkNetnsService =
    name: instance:
    lib.nameValuePair "amnezia-netns-${name}" {
      description = "Create Amnezia VPN network namespace ${name}";
      before = [
        "amnezia-config-${name}.service"
        "wg-quick-${name}.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.coreutils
        pkgs.iproute2
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ip netns delete ${name} 2>/dev/null || true
        ip link delete ${mkHostInterface name} 2>/dev/null || true

        ip netns add ${name}
        ip link add ${mkHostInterface name} type veth peer name ${mkNamespaceInterface name}

        ip address add ${instance.hostAddress}/30 dev ${mkHostInterface name}
        ip link set ${mkHostInterface name} up

        ip link set ${mkNamespaceInterface name} netns ${name}
        ip -n ${name} address add ${instance.namespaceAddress}/30 dev ${mkNamespaceInterface name}
        ip -n ${name} link set lo up
        ip -n ${name} link set ${mkNamespaceInterface name} up
        ip -n ${name} route add default via ${instance.hostAddress}

        install -d -m 0755 /etc/netns/${name}
        printf '%s\n' ${mkNameserverArgs instance.dns} > ${mkResolvConf name}
      '';
      preStop = ''
        ${pkgs.iproute2}/bin/ip netns delete ${name} 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip link delete ${mkHostInterface name} 2>/dev/null || true
      '';
    };

  mkConfigService =
    name: instance:
    lib.nameValuePair "amnezia-config-${name}" {
      description = "Prepare Amnezia VPN config ${name}";
      requires = [ "amnezia-netns-${name}.service" ];
      after = [
        "amnezia-netns-${name}.service"
        "sops-nix.service"
      ];
      before = [ "wg-quick-${name}.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [
        pkgs.coreutils
        pkgs.gnused
      ];
      script = ''
        install -d -m 0700 /run/duck-vpn/amnezia
        sed '/^[[:space:]]*DNS[[:space:]]*=/d' ${instance.configFile} > ${mkRuntimeConfig name}
        chmod 0400 ${mkRuntimeConfig name}
      '';
    };

  mkWgQuickInterface = name: _: {
    type = "amneziawg";
    configFile = mkRuntimeConfig name;
  };

  mkWgQuickService =
    name: instance:
    lib.nameValuePair "wg-quick-${name}" {
      requires = [
        "amnezia-netns-${name}.service"
        "amnezia-config-${name}.service"
      ];
      after = [
        "amnezia-netns-${name}.service"
        "amnezia-config-${name}.service"
        "sops-nix.service"
      ];
      before = map (service: "${service}.service") instance.services;
      serviceConfig = {
        NetworkNamespacePath = "/run/netns/${name}";
        BindReadOnlyPaths = [ "${mkResolvConf name}:/etc/resolv.conf" ];
      };
    };

  mkNamespacedServiceConfigs =
    name: instance:
    lib.genAttrs instance.services (_: {
      requires = [ "wg-quick-${name}.service" ];
      after = [ "wg-quick-${name}.service" ];
      serviceConfig = {
        NetworkNamespacePath = "/run/netns/${name}";
        BindReadOnlyPaths = [ "${mkResolvConf name}:/etc/resolv.conf" ];
      };
    });

  namespacedServiceConfigs = lib.foldl' lib.recursiveUpdate { } (
    lib.mapAttrsToList mkNamespacedServiceConfigs enabledInstances
  );
in
{
  options.duck.vpn.amnezia.instances = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "this Amnezia VPN namespace" // {
            default = true;
          };

          configFile = lib.mkOption {
            type = lib.types.str;
            description = "Path to an AmneziaWG wg-quick compatible configuration file.";
          };

          externalInterface = lib.mkOption {
            type = lib.types.str;
            description = "Host interface used for namespace NAT before the VPN tunnel is up.";
          };

          hostAddress = lib.mkOption {
            type = lib.types.str;
            description = "Host-side veth IPv4 address without prefix length.";
          };

          namespaceAddress = lib.mkOption {
            type = lib.types.str;
            description = "Namespace-side veth IPv4 address without prefix length.";
          };

          dns = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "DNS servers exposed inside the namespace.";
          };

          services = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Systemd service names to run inside this VPN namespace.";
          };
        };
      }
    );
    default = { };
  };

  config = lib.mkIf (enabledInstances != { }) {
    assertions = [
      {
        assertion =
          lib.length (
            lib.unique (map (instance: instance.externalInterface) (lib.attrValues enabledInstances))
          ) == 1;
        message = "duck.vpn.amnezia currently supports one NAT externalInterface per host.";
      }
    ];

    networking.nat = {
      enable = true;
      externalInterface = (lib.head (lib.attrValues enabledInstances)).externalInterface;
      internalInterfaces = map mkHostInterface (lib.attrNames enabledInstances);
    };

    networking.wg-quick.interfaces = lib.mapAttrs mkWgQuickInterface enabledInstances;

    systemd.services =
      lib.mapAttrs' mkNetnsService enabledInstances
      // lib.mapAttrs' mkConfigService enabledInstances
      // lib.mapAttrs' mkWgQuickService enabledInstances
      // namespacedServiceConfigs;
  };
}
