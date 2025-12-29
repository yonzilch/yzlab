_: {
  disko.devices = {
    disk = {
      hdd = {
        type = "disk";
        device = "/dev/disk/by-path/virtio-pci-0000:00:0b.0";
        content = {
          type = "gpt";
          partitions = {
            vdb1 = {
              content = {
                type = "zfs";
                pool = "hdd";
              };
              size = "100%";
            };
          };
        };
      };
    };
    zpool = {
      hdd = {
        type = "zpool";
        datasets = {
          "hdd" = {
            mountpoint = "/hdd";
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
      };
    };
  };
}
