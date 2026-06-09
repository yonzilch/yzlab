{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/virtio-pci-0000:00:07.0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/optional/podman.nix
      ../../modules/optional/tmux.nix
      ../../modules/optional/zfs.nix
      ../../modules/options/hermes-agent-dashboard.nix
      ../../modules/options/komari-agent.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.kernelParams = [
    "zfs.zfs_arc_max=1073741824" # 1GB
  ];
  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "f9e0c106";
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
