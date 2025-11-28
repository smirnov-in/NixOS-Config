{
  description = "NixOS config flake";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/latest";
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

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-niri = {
      url = "github:sodiboo/niri-flake";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    configLib = import ./lib {inherit lib;};
  in {
    nixosConfigurations = {
      pond = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs configLib;};
        modules = [
          ./hosts/pond
        ];
      };

      owlery = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs configLib;};
        modules = [
          ./hosts/owlery
        ];
      };
    };

    homeConfigurations."duck@pond" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = {inherit inputs configLib;};
      modules = [
        ./home/duck/pond
      ];
    };
  };
}
