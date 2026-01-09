_: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        content = {
          partitions = {
            boot = {
              attributes = [0];
              priority = 1;
              size = "1M";
              type = "EF02";
            };
            esp = {
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = ["umask=0077"];
                mountpoint = "/boot";
              };
              priority = 2;
              size = "1G";
              type = "EF00";
            };
            zfs = {
              content = {
                pool = "zroot";
                type = "zfs";
              };
              size = "100%";
            };
          };
          type = "gpt";
        };
      };
    };
    zpool = {
      zroot = {
        datasets = {
          "root" = {
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
            type = "zfs_fs";
          };
        };
        options = {
          ashift = "12";
          compatibility = "grub2";
        };
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "lz4";
          mountpoint = "none";
          xattr = "sa";
        };
        type = "zpool";
      };
    };
  };
}
