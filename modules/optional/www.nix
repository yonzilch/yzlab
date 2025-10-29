_: {
  users = {
    groups = {www = {};};
    users.www = {
      createHome = true;
      home = "/home/www";
      name = "www";
      group = "www";
      isSystemUser = true;
    };
  };
}
