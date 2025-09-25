{lib, ...}: {
  networking = {
    firewall.enable = lib.mkForce false;
    useDHCP = lib.mkForce false;
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "192.168.122.205";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.122.1";
      interface = "eth0";
    };
  };
}
