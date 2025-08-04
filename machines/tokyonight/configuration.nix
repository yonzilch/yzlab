{lib, ...}: let
  hostname = "tokyonight";
  ls = lib.filesystem.listFilesRecursive;
  primary-device = "/dev/disk/by-path/virtio-pci-0000:00:07.0";
in {
  imports =
    [
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

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8wO1Yfm9Nx4fZpaIfxAsvb6MJQW4lh1Sid9AQN4gFn root@tokyonight
    ''
  ];
}
