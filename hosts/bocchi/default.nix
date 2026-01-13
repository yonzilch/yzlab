{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
      ../../modules/options/komari-agent.nix
    ]
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "d9563534";
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
