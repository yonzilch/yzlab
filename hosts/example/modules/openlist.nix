_: {
  services.openlist = {
    enable = true;
    # user = "root";
  };
  systemd.services.alist-server.environment = {
    SITE_URL = "https://openlist.example.com";
  };
}
