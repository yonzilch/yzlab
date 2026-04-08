{lib, ...}: {
  imports = [];

  boot.initrd.availableKernelModules = [
    "virtio_scsi"
    "sd_mod"
    "ahci"
    "ata_piix"
    "virtio_pci"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/528855f2-ad33-4562-bf3e-2c9fc86e0b67";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/10AE-04AD";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
