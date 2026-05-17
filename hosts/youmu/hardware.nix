{lib, ...}: {
  imports = [];

  boot.initrd.availableKernelModules = [
    "sd_mod"
    "ahci"
    "ata_piix"
    "virtio_pci"
    "xen_blkfront"
    "hv_storvsc"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ccfca046-d25b-4b17-a195-c4749b147480";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/567E-E98D";
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
