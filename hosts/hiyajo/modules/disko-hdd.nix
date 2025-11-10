_: {
  disko.devices = {
    disk = {
      hdd = {
        type = "disk";
        device = "/dev/disk/by-path/virtio-pci-0000:00:07.0";
        content = {
          type = "gpt";
          partitions = {
            vdb1 = {
              content = {
                type = "filesystem";
                format = "f2fs";
                mountpoint = "/hdd";
                extraArgs = [
                  "-O"
                  "extra_attr,inode_checksum,sb_checksum,compression"
                ];
                mountOptions = [
                  "compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime,nodiscard"
                ];
              };
              size = "100%";
            };
          };
        };
      };
    };
  };
}
