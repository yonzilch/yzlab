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
    ../../modules/options/dn42.nix
    ../../modules/options/komari-agent.nix
    ../../modules/optional/terminal-implement.nix
    ../../modules/optional/www.nix
    ../../modules/optional/zfs.nix
    ../../modules/options/st.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.kernelParams = [
    "zfs.zfs_arc_max=107374182" # 0.1GB
  ];
  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "9d7bf78d";
  system.stateVersion = "26.11";
  zramSwap.enable = true;
}
