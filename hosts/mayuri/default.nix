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
      ../../modules/optional/komari-agent.nix
      ../../modules/optional/komari-server.nix
      ../../modules/optional/podman.nix
      ../../modules/optional/qbee.nix
      ../../modules/optional/st.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  boot.kernelParams = [
    "zfs.zfs_arc_max=1073741824" # 1GB
  ];
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "bb26b3c5";
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
