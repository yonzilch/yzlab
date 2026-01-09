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
              size = "256M";
              type = "EF00";
            };
            root = {
              size = "100%";
              content = {
                extraArgs = [
                  "-O"
                  "extra_attr,inode_checksum,sb_checksum,compression"
                ];
                format = "f2fs";
                mountOptions = [
                  "compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime,nodiscard"
                ];
                mountpoint = "/";
                type = "filesystem";
              };
            };
          };
          type = "gpt";
        };
      };
    };
  };
}
