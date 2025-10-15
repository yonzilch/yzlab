_: {
  users = {
    groups.www = {};
    users = {
      www = {
        name = "www";
        group = "www";
        isSystemUser = false;
        home = "/home/www";
        createHome = true;
      };
    };
  };

  services.polaris = {
    enable = true;
    user = "www";
    group = "www";
    port = 5050;
    settings = {
      settings.reindex_every_n_seconds = 7 * 24 * 60 * 60; # weekly, default is 1800
      settings.album_art_pattern = "(cover|front|folder)\.(jpeg|jpg|png|bmp|gif)";
      mount_dirs = [
        {
          name = "Music";
          source = "/home/www/Music";
        }
      ];
    };
  };
}
