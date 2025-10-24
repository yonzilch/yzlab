_: {
  networking.firewall.allowedTCPPorts = [7000 25565];

  services.frp = {
    enable = true;
    role = "server";
    settings = {
      auth.token = "xxxxxx";
      bindAddr = "0.0.0.0";
      bindPort = 7000;
    };
  };
}
