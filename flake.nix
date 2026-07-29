{
  description = "NixOS config flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };

    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Remove after the Niri module reaches a matching Home Manager release.
    home-manager-niri = {
      url = "github:nix-community/home-manager/3221e226aa49a94cbc0e82107535ae435da42ef3";
      flake = false;
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/v0.7.0";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/smirnov-in/NixOS-Secrets.git?ref=main&shallow=1";
      flake = false;
    };

    nix-catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
    };
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      configLib = import ./lib { inherit lib; };
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        pond = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs configLib; };
          modules = [
            ./hosts/pond
          ];
        };

        owlery = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs configLib; };
          modules = [
            ./hosts/owlery
          ];
        };

        nest = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs configLib; };
          modules = [
            ./hosts/nest
          ];
        };
      };

      devShells.${system}.default = pkgsUnstable.mkShell {
        packages = with pkgsUnstable; [
          codex
          mcp-nixos
          nixfmt-tree
        ];
      };
    };
}
