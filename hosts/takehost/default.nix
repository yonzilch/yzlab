{
  hostname,
  lib,
  ...
}:
let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:00:05.0-scsi-0:0:0:0";
in
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/options/komari-agent.nix
    ../../modules/optional/terminal-implement.nix
    ../../modules/optional/zfs.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "3f70d062";
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
