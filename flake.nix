{
  description = "OpenYZLab Infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixfmt-rs = {
      url = "github:Mic92/nixfmt-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
    yonos.url = "github:yonzilch/yonos";
  };

  outputs =
    inputs:
    let
      hostname = "example";
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [ "x86_64-linux" ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          treefmt = {
            projectRootFile = "flake.nix";

            programs = {
              deadnix.enable = true;

              nixfmt = {
                enable = true;
                package = inputs.nixfmt-rs.packages.${system}.default;
              };
            };

            settings.formatter = {
              deadnix.priority = 0;
              nixfmt.priority = 1;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              compose2nix
              config.treefmt.build.wrapper
              gitleaks
              nixos-rebuild
              nixos-rebuild-ng
              pre-commit
              rage
              sops
            ];
          };
        };

      flake = {
        nixosConfigurations = {
          "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hosts ];
            specialArgs = { inherit hostname inputs; };
          };
        };
      };
    };
}
