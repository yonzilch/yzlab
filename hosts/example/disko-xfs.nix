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
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
                type = "filesystem";
              };
              priority = 2;
              size = "256M";
              type = "EF00";
            };
            root = {
              content = {
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
                format = "xfs";
                mountOptions = [
                  "allocsize=128k,logbsize=256k,inode64,largeio,nodiscard,noatime,swalloc"
                ];
                mountpoint = "/";
                type = "filesystem";
              };
              size = "100%";
            };
          };
          type = "gpt";
        };
      };
    };
  };
}
