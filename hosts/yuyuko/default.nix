{
  hostname,
  lib,
  ...
}:
let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/virtio-pci-0000:00:07.0";
in
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/optional/podman.nix
    ../../modules/optional/terminal-implement.nix
    ../../modules/optional/www.nix
    ../../modules/optional/zfs.nix
    ../../modules/options/dufs.nix
    ../../modules/options/komari-agent.nix
    ../../modules/options/openlist.nix
    ../../modules/options/st.nix
    ../../modules/options/xl.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.kernelParams = [
    "zfs.zfs_arc_max=107374182" # 0.1GB
  ];
  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "3e625d47";
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
