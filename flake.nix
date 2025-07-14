{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nur.url = "github:nix-community/NUR";
    systems.url = "github:nix-systems/default-linux";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/testing";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
    };

    mcphub-nvim = {
      url = "github:ravitemer/mcphub.nvim";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      nix-on-droid,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      lib = nixpkgs.lib;
      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfreePredicate = (pkg: true);
          };
        }
      );
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      rootPath = ./.;
    in
    {
      username = "idjo";

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);
      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      nixOnDroidModules = import ./modules/nix-on-droid;

      nixosConfigurations = {
        ox = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs rootPath;
          };
          modules = [
            ./hosts/ox/config.nix
          ];
        };

        horse = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs rootPath;
          };
          modules = [
            ./hosts/horse/config.nix
          ];
        };

        tiger = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs rootPath;
          };
          modules = [
            ./hosts/tiger/nixos/configuration.nix
          ];
        };
      };

      nixOnDroidConfigurations = {
        monkey = nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          extraSpecialArgs = {
            inherit inputs outputs rootPath;
          };
          modules = [
            ./hosts/monkey/config.nix
          ];
        };

        rabbit = nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          extraSpecialArgs = {
            inherit inputs outputs rootPath;
          };
          modules = [
            ./hosts/rabbit/config.nix
          ];
        };
      };
    };
}
