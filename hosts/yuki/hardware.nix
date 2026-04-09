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
    device = "/dev/disk/by-uuid/211b1d55-5498-4fb1-936a-d50687521580";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/EB28-C70E";
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
