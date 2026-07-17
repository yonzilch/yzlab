{
  hostname,
  lib,
  ...
}:
let
  ls = lib.filesystem.listFilesRecursive;
in
{
  imports = [
    ./hardware.nix
    ../../modules/options/komari-agent.nix
    ../../modules/options/xl.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.loader = {
    efi = {
      efiSysMountPoint = "/efi";
      canTouchEfiVariables = true;
    };
    limine.enable = lib.mkForce false;
    systemd-boot.enable = true;
  };
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
