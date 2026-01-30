{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nur.url = "github:nix-community/NUR";
    systems.url = "github:nix-systems/default";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-on-droid,
      nix-darwin,
      systems,
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
          overlays = [
            (import ./overlays { inherit inputs; }).additions
            (import ./overlays { inherit inputs; }).modifications
            (import ./overlays { inherit inputs; }).stable-packages
            (import ./overlays { inherit inputs; }).llm-agents
          ];
        }
      );
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      rootPath = ./.;
    in
    {
      username = "idjo";

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixfmt);
      overlays = import ./overlays { inherit inputs; };

      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;
      darwinModules = import ./modules/darwin;
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

      darwinConfigurations = {
        snake = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs rootPath;
          };
          modules = [
            ./hosts/snake/config.nix
            {
              system.configurationRevision = self.rev or self.dirtyRev or null;
            }
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

      # Standalone Home Manager configurations for `nh home switch`
      homeConfigurations = {
        # NixOS hosts (Linux)
        "idjo@ox" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs rootPath;
            hostName = "ox";
          };
          modules = [
            ./hosts/ox/home.nix
          ];
        };

        "idjo@horse" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs rootPath;
            hostName = "horse";
          };
          modules = [
            ./hosts/horse/home.nix
          ];
        };

        "idjo@tiger" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs rootPath;
            hostName = "tiger";
          };
          modules = [
            ./hosts/tiger/home-manager/home.nix
          ];
        };

        # Darwin host (macOS)
        "idjo@snake" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.aarch64-darwin;
          extraSpecialArgs = {
            inherit inputs outputs rootPath;
            hostName = "snake";
          };
          modules = [
            ./hosts/snake/home.nix
          ];
        };
      };
    };
}
