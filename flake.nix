{
  description = "OpenYZLab Infra";

  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hermes-agent.url = "github:NousResearch/hermes-agent";

    nixfmt-rs = {
      url = "github:Mic92/nixfmt-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim.url = "github:nix-community/nixvim/nixos-26.05";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yonos.url = "github:yonzilch/yonos";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;

      hostsDirectory = ./hosts;

      excludedHosts = [
        "example"
      ];

      hostEntries = builtins.readDir hostsDirectory;

      hostnames = builtins.filter (
        hostname:
        hostEntries.${hostname} == "directory"
        && !(builtins.elem hostname excludedHosts)
        && builtins.pathExists (hostsDirectory + "/${hostname}/default.nix")
      ) (builtins.attrNames hostEntries);

      mkHost =
        hostname:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./hosts
          ];

          specialArgs = {
            inherit hostname inputs;
          };
        };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake = {
        nixosConfigurations = lib.genAttrs hostnames mkHost;
      };

      systems = [
        "x86_64-linux"
      ];

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
    };
}
