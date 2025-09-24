{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/virtio-pci-0000:00:08.0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/optional/podman.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    ++ ls ./modules
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "156721ca";
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
