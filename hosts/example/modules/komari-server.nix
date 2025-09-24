_: {
  services.komari-server = {
    enable = true;
    # openFirewall = false;
    # port = "25574";
    # user = "komari-server";
    # group = "komari-server";
  };
  systemd.services.komari-server.environment = {
    ADMIN_USERNAME = "foobar";
    ADMIN_PASSWORD = "xxxxxx";
  };
}
