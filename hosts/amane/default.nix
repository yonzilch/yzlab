{
  hostname,
  lib,
  ...
}:
let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/virtio-pci-0000:00:06.0";
in
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/optional/terminal-implement.nix
    ../../modules/optional/zfs.nix
    ../../modules/options/komari-agent.nix
    ../../modules/options/qb.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "d453f1a2";
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
