{lib, ...}: let
  hostname = "victoria";
  ls = lib.filesystem.listFilesRecursive;
  primary-device = "/dev/disk/by-path/virtio-pci-0000:00:07.0";
in {
  imports =
    [
      ../../modules/optional/podman.nix
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
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGrznY1P4zQX60W3vyg1zZlnKH8MZs9RL4RUC0PcHiI root@victoria
    ''
  ];
}
