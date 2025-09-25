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
                  "size=4096" # block size
                  "-i"
                  "size=512" # inode size
                  "-l"
                  "size=128m" # log size
                  "-n"
                  "size=8192" # directory block size
                  "-s"
                  "size=4096" # sector size
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
