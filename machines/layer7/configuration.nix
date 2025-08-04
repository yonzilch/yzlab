{lib, ...}: let
  hostname = "layer7";
  ls = lib.filesystem.listFilesRecursive;
  primary-device = "/dev/disk/by-path/virtio-pci-0000:00:0a.0";
in {
  imports =
    [
      ../../modules/optional/qb.nix
      ../../modules/optional/qbee.nix
      ../../modules/optional/st.nix
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
    ++ ls ./modules
    ++ ls ../../modules/shared
    ++ ls ../../sops/eval/${hostname};

  boot.loader.limine = {
    biosDevice = lib.mkForce primary-device;
  };

  clan.core.networking = {
    targetHost = "root@${hostname}";
  };

  disko.devices.disk.main.device = primary-device;

  users.users.root.openssh.authorizedKeys.keys = [
    ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYA9+GwVMqoxxuAK5DImKASIozfItnpOoZ0KqkG1dRI root@layer7
    ''
  ];
}
