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
      ./hardware.nix
      ../../modules/options/komari-agent.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  disko.devices.disk.main.device = primary-disk;
  system.stateVersion = "26.05";
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
}
