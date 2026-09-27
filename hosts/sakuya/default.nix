{
  hostname,
  lib,
  ...
}:
let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:00:1f.2-ata-1";
in
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/optional/terminal-implement.nix
    ../../modules/options/komari-agent.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  system.stateVersion = "26.11";
  zramSwap.enable = true;
}
