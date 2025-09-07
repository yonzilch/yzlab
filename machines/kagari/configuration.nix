{lib, ...}: let
  hostname = "kagari";
  ls = lib.filesystem.listFilesRecursive;
  primary-device = "/dev/disk/by-path/pci-0000:00:09.0-scsi-0:0:0:0";
in {
  imports =
    [
      ../../modules/optional/terminal-implement.nix
      ../../modules/optional/zfs.nix
    ]
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
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZ7KdjaExcJA6cWtB7Z/l53N4QJMHvnQJodYEF+pGEI root@kagari
    ''
  ];

  zramSwap.enable = true;
}
