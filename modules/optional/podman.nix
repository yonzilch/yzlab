_: {
  virtualisation = {
    containers = {
      containersConf.settings = {
        containers.dns_servers = [
          # These are Maleware Blocking DNS Servers
          # Cloudflare
          "1.1.1.2"
          "1.0.0.2"
          "2606:4700:4700::1112"
          "2606:4700:4700::1002"
          # quad9
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
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
