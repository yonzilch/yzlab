_: {
  users = {
    groups = {
      www = {};
    };
    users.www = {
      createHome = true;
      home = "/home/www";
      name = "www";
      group = "www";
      isSystemUser = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/www 0755 www www - -"
  ];
}
