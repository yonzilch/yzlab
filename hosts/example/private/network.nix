{lib, ...}: {
  networking = {
    useDHCP = lib.mkForce false;
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "1.0.0.1";
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = "2606:4700:4700::1001";
          prefixLength = 48;
        }
      ];
    };
    defaultGateway = {
      address = "1.1.1.1";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "2606:4700:4700::1111";
      interface = "eth0";
    };
  };
}
