{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:00:09.0-scsi-0:0:0:0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/optional/qb.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "9b93aa76";
  networking.hostName = hostname;
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
