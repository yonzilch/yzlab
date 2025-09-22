_: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            esp = {
              size = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
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
            };
          };
        };
      };
    };
  };
}
