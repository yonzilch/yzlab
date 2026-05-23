{lib, ...}: {
  imports = [];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "ahci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
