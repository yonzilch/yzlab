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
      ../../modules/optional/komari-agent.nix
      ../../modules/optional/terminal-implement.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
