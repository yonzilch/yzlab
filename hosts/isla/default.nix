{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:04:00.0-scsi-0:0:0:0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostName = hostname;
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
