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
                type = "filesystem";
                format = "xfs";
                mountpoint = "/hdd";
                extraArgs = [
                  "-b"
                  "size=4096" # 4KB 块大小
                  "-i"
                  "size=512" # inode 大小
                  "-l"
                  "size=128m" # 日志大小
                  "-n"
                  "size=8192" # 目录块大小
                  "-s"
                  "size=4096" # 扇区大小 4KB
                ];
                mountOptions = [
                  "allocsize=128k,logbsize=256k,inode64,largeio,nodiscard,noatime,swalloc"
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
