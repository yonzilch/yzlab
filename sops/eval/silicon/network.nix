{lib, ...}: {
  networking.useDHCP = lib.mkForce false;
  systemd.network = {
    enable = true;
    networks.eth0 = {
      address = [
        "173.249.210.199/24"
        "2607:9000:800:50c3::a/64"
      ];
      gateway = ["173.249.210.1"];
      matchConfig.Name = "eth0";
      networkConfig = {
        IPv6AcceptRA = false;
      };
      routes = [
        {
          Gateway = "2607:9000:800:5000::1";
          GatewayOnLink = true;
        }
      ];
    };
  };
}
