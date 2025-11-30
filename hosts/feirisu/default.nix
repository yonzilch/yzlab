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
    ../../modules/options/komari-agent.nix
    ../../modules/options/openlist.nix
    ../../modules/options/st.nix
    ../../modules/optional/terminal-implement.nix
  ]
  ++ ls ../../modules/private/${hostname}
  ++ ls ../../modules/shared;

  boot.loader.limine.biosDevice = primary-disk;
  disko.devices.disk.main.device = primary-disk;
  system.stateVersion = "26.05";
  zramSwap.enable = true;
}
