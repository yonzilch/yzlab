{
  hostname,
  lib,
  ...
}:
let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:01:01.0-scsi-0:0:0:0";
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

  boot.kernelParams = [
    "zfs.zfs_arc_max=1073741824" # 1GB
  ];
  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "52c10e9b";
  system.stateVersion = "26.11";
  zramSwap.enable = true;
}
