{
  services.frp = {
    enable = true;
    role = "client";
    settings = {
      auth.token = "xxxxxx";
      serverAddr = "1.1.1.1";
      serverPort = 7000;

      proxies = [
        {
          name = "mc";
          type = "tcp";
          localIP = "127.0.0.1";
          localPort = 25565;
          remotePort = 25565;
        }
      ];
    };
  };
}
