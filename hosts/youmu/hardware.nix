{ lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "sd_mod"
    "ahci"
    "ata_piix"
    "virtio_pci"
    "xen_blkfront"
    "hv_storvsc"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5fca9cc7-515f-4e8c-bf15-883af8b53bb2";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/AB4F-3359";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
