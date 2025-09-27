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
      ../../modules/optional/komari-agent.nix
      ../../modules/optional/openlist.nix
      ../../modules/optional/qb.nix
      ../../modules/optional/qbee.nix
      ../../modules/optional/st.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/wget.nix
    ]
    ++ ls ./modules
    ++ ls ../../modules/private/${hostname}
    ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  system.stateVersion = "25.11";
  zramSwap.enable = true;
}
