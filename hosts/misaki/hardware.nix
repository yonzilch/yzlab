{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader = {
    efi.efiSysMountPoint = "/efi";
    limine.enable = lib.mkForce false;
    systemd-boot.enable = true;
  };
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
    device = "/dev/disk/by-uuid/8374a911-5564-4a48-b105-e84756e3e4db";
    fsType = "ext4";
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/5AD8-83EE";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  networking.useDHCP = lib.mkForce true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.hypervGuest.enable = true;
}
