{lib, ...}: {
  networking = {
    useDHCP = lib.mkForce false;
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "192.168.122.101";
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
