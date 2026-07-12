{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  ldapBaseDn = "dc=duck,dc=home";
  autheliaStateDir = "/var/lib/authelia-main";
  lldapStateDir = "/var/lib/lldap";
  backupDir = "/srv/backups/identity";
in
{
  config = lib.mkMerge [
    {
      sops.secrets = {
        "nest/authelia/jwt-secret" = {
          owner = "authelia-main";
          group = "authelia-main";
        };

        "nest/authelia/storage-encryption-key" = {
          owner = "authelia-main";
          group = "authelia-main";
        };

        "nest/authelia/oidc-hmac-secret" = {
          owner = "authelia-main";
          group = "authelia-main";
        };

        "nest/authelia/oidc-issuer-private-key" = {
          owner = "authelia-main";
          group = "authelia-main";
        };

        "nest/authelia/oidc/immich-client-secret-digest" = {
          owner = "authelia-main";
          group = "authelia-main";
        };

        "nest/authelia/oidc/nextcloud-client-secret-digest" = {
          owner = "authelia-main";
          group = "authelia-main";
        };

        "nest/lldap/admin-password" = {
          owner = "root";
          group = "authelia-main";
          mode = "0440";
        };
      };

      sops.templates."authelia-domain.yml" = {
        owner = "authelia-main";
        group = "authelia-main";
        mode = "0400";
        restartUnits = [ "authelia-main.service" ];
        content = ''
          access_control:
            rules:
              - domain: auth.${config.sops.placeholder."nest/domain"}
                policy: one_factor
              - domain: ${config.sops.placeholder."nest/domain"}
                policy: one_factor
                subject:
                  - group:admins

          session:
            cookies:
              - domain: ${config.sops.placeholder."nest/domain"}
                authelia_url: https://auth.${config.sops.placeholder."nest/domain"}
                default_redirection_url: https://${config.sops.placeholder."nest/domain"}
        '';
      };

      sops.templates."authelia-oidc-clients.yml" = {
        owner = "authelia-main";
        group = "authelia-main";
        mode = "0400";
        restartUnits = [ "authelia-main.service" ];
        content = ''
          identity_providers:
            oidc:
              clients:
                - client_id: immich
                  client_name: Immich
                  client_secret: '${config.sops.placeholder."nest/authelia/oidc/immich-client-secret-digest"}'
                  redirect_uris:
                    - https://immich.${config.sops.placeholder."nest/domain"}/auth/login
                    - app.immich:///oauth-callback
                  scopes:
                    - openid
                    - email
                    - profile
                  authorization_policy: one_factor
                  require_pkce: true
                  pkce_challenge_method: S256
                  token_endpoint_auth_method: client_secret_post
                - client_id: nextcloud
                  client_name: Nextcloud
                  client_secret: '${
                    config.sops.placeholder."nest/authelia/oidc/nextcloud-client-secret-digest"
                  }'
                  redirect_uris:
                    - https://nextcloud.${config.sops.placeholder."nest/domain"}/apps/oidc_login/oidc
                  scopes:
                    - openid
                    - email
                    - profile
                  authorization_policy: one_factor
                  require_pkce: true
                  pkce_challenge_method: S256
                  token_endpoint_auth_method: client_secret_basic
        '';
      };

      services.authelia.instances.main = {
        enable = true;
        secrets = {
          jwtSecretFile = config.sops.secrets."nest/authelia/jwt-secret".path;
          storageEncryptionKeyFile = config.sops.secrets."nest/authelia/storage-encryption-key".path;
          oidcHmacSecretFile = config.sops.secrets."nest/authelia/oidc-hmac-secret".path;
          oidcIssuerPrivateKeyFile = config.sops.secrets."nest/authelia/oidc-issuer-private-key".path;
        };
        environmentVariables = {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
            config.sops.secrets."nest/lldap/admin-password".path;
        };
        settingsFiles = [
          config.sops.templates."authelia-domain.yml".path
          config.sops.templates."authelia-oidc-clients.yml".path
        ];
        settings = {
          theme = "auto";
          default_2fa_method = "totp";

          server = {
            address = "tcp://127.0.0.1:9091/";
            endpoints.authz."forward-auth" = {
              implementation = "ForwardAuth";
              authn_strategies = [
                {
                  name = "CookieSession";
                }
              ];
            };
          };

          log = {
            level = "info";
            format = "text";
          };

          authentication_backend.ldap = {
            implementation = "lldap";
            address = "ldap://127.0.0.1:3890";
            base_dn = ldapBaseDn;
            additional_users_dn = "ou=people";
            additional_groups_dn = "ou=groups";
            users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
            groups_filter = "(&(member={dn})(objectClass=groupOfNames))";
            user = "uid=admin,ou=people,${ldapBaseDn}";
            attributes = {
              username = "uid";
              display_name = "cn";
              mail = "mail";
              group_name = "cn";
            };
          };

          access_control.default_policy = "deny";

          storage.local.path = "${autheliaStateDir}/db.sqlite3";

          notifier.filesystem.filename = "${autheliaStateDir}/notifications.txt";
        };
      };

      services.lldap = {
        enable = true;
        environment = {
          LLDAP_LDAP_USER_PASS_FILE = "/run/credentials/lldap.service/admin-password";
        };
        settings = {
          ldap_host = "127.0.0.1";
          ldap_port = 3890;
          http_host = "127.0.0.1";
          http_port = 17170;
          ldap_base_dn = ldapBaseDn;
          ldap_user_dn = "admin";
          ldap_user_email = "admin@duck.home";
          force_ldap_user_pass_reset = "always";
        };
      };

      systemd.services.lldap.serviceConfig.LoadCredential = [
        "admin-password:${config.sops.secrets."nest/lldap/admin-password".path}"
      ];

      services.caddy.extraConfig = lib.mkMerge [
        (lib.mkBefore ''
          (authelia_forward_auth) {
            forward_auth 127.0.0.1:9091 {
              uri /api/authz/forward-auth?authelia_url=https://auth.{$NEST_DOMAIN}/
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
            }
          }
        '')
        ''
          auth.{$NEST_DOMAIN} {
            reverse_proxy 127.0.0.1:9091
          }

          lldap.{$NEST_DOMAIN} {
            import lan_only
            reverse_proxy 127.0.0.1:17170
          }
        ''
      ];

      nest.dashboard.groups.services = [
        {
          Authelia = {
            href = "/auth";
            description = "SSO";
          };
        }
        {
          LLDAP = {
            href = "/lldap";
            description = "Directory";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/auth";
          target = "auth";
        }
        {
          path = "/lldap";
          target = "lldap";
        }
      ];

      nest.backups.local.jobs.identity = {
        description = "Back up identity state";
        after = [
          "authelia-main.service"
          "lldap.service"
        ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "identity-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/identity-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          workdir="$(${pkgs.coreutils}/bin/mktemp -d "${backupDir}/.identity-backup.XXXXXX")"
          authelia_was_active=false
          lldap_was_active=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -rf "$workdir" "$archive_tmp"
            if [ "$lldap_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start lldap.service || true
            fi
            if [ "$authelia_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start authelia-main.service || true
            fi
          }
          trap cleanup EXIT

          if ${pkgs.systemd}/bin/systemctl is-active --quiet authelia-main.service; then
            authelia_was_active=true
            ${pkgs.systemd}/bin/systemctl stop authelia-main.service
          fi

          if ${pkgs.systemd}/bin/systemctl is-active --quiet lldap.service; then
            lldap_was_active=true
            ${pkgs.systemd}/bin/systemctl stop lldap.service
          fi

          ${pkgs.coreutils}/bin/install --directory "$workdir/var/lib"
          ${pkgs.coreutils}/bin/cp --archive ${autheliaStateDir} "$workdir/var/lib/"
          ${pkgs.coreutils}/bin/cp --archive ${lldapStateDir} "$workdir/var/lib/"

          ${pkgs.gnutar}/bin/tar \
            --create \
            --directory "$workdir" \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            .

          ${pkgs.coreutils}/bin/mv "$archive_tmp" "$archive"
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        autheliaStateDir
        backupDir
        lldapStateDir
      ];
    })
  ];
}
