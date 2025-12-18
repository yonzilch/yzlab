{
  description = "Yon Zilch's Mirai Gajetto Lab";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };
  outputs = inputs: let
    hostname = "example";
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            compose2nix
            deadnix
            nixos-rebuild
            nixos-rebuild-ng
            rage
            sops
          ];
        };
      };
      flake = {
        nixosConfigurations = {
          "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [./hosts];
            specialArgs = {inherit hostname inputs;};
          };
        };
      };
    };
}
