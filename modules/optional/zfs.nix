{lib, ...}:
with lib; {
  boot = {
    kernelParams = ["zfs_force=1"];
    zfs = {
      forceImportRoot = false;
      devNodes = "/dev/disk/by-path";
    };
  };
  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    trim = {
      enable = false;
      interval = "weekly";
    };
  };
  systemd.services = {
    zfs-share.enable = mkForce false;
    zfs-zed.enable = mkForce false;
  };
}
