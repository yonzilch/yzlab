_: {
  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [222];
    settings = {
      AllowUsers = null;
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
      PubkeyAuthentication = "yes";
      UseDns = false;
      X11Forwarding = false;
    };
  };
}
