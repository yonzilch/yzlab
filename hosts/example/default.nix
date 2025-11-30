{
  hostname,
  lib,
  ...
}: let
  ls = lib.filesystem.listFilesRecursive;
  primary-disk = "/dev/disk/by-path/xxxxxx";
in {
  imports =
    [
      ./disko.nix
      ./hardware.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    # ++ ls ./modules
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  networking.hostId = "xxxxxx"; # use command `head -c4 /dev/urandom | od -A none -t x4` to generate
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
