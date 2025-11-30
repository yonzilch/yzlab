{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:01:01.0-scsi-0:0:0:0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/options/komari-agent.nix
      ../../modules/options/komari-server.nix
      ../../modules/options/openlist.nix
      ../../modules/options/qb.nix
      ../../modules/options/qbee.nix
      ../../modules/options/st.nix
      ../../modules/optional/podman.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  boot.kernelParams = [
    "zfs.zfs_arc_max=4294967296" # 4GB
  ];
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "bb26b3c5";
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
