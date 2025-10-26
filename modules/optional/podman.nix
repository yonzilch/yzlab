_: {
  virtualisation = {
    containers = {
      containersConf.settings = {
        containers.dns_servers = [
          "185.222.222.222"
          "45.11.45.11"
          "9.9.9.9"
          "149.112.112.112"
          "2a0d:2a00:1::2"
          "2a0d:2a00:2::2"
        ];
      };
      enable = true;
      storage.settings = {
        storage.driver = "zfs";
        storage.graphroot = "/var/lib/containers/storage";
        storage.runroot = "/run/containers/storage";
        storage.options.zfs.fsname = "zroot/root";
      };
    };
    oci-containers.backend = "podman";
    podman = {
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
        subnets = [
          {
            subnet = "10.88.0.0/16";
            gateway = "10.88.0.1";
          }
          {
            subnet = "fd00:db8::/64";
            gateway = "fd00:db8::1";
          }
        ];
      };
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
}
