_: {
  services.openlist = {
    enable = true;
    # user = "root";
  };
  systemd.services.openlist.environment = {
    SITE_URL = "https://openlist.example.com";
  };
}
