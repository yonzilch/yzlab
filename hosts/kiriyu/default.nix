{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/virtio-pci-0000:07:00.0";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/options/komari-agent.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "3f70d062";
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
