{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/virtio-pci-0000:00:06.0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/optional/podman.nix
      ../../modules/optional/zfs.nix
      ../../modules/options/komari-agent.nix
      ../../modules/options/qb.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "d453f1a2";
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
