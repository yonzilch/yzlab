_: {
  virtualisation.oci-containers.containers."redlib" = {
    image = "quay.io/redlib/redlib:latest";
    environment = {
      "PORT" = "58080";
      "REDLIB_DEFAULT_SHOW_NSFW" = "on";
      "REDLIB_DEFAULT_THEME" = "dark";
      "REDLIB_DEFAULT_WIDE" = "on";
      "ROBOTS_DISABLE_INDEXING" = "on";
    };
    ports = [
      "127.0.0.1:58080:58080"
    ];
  };
}
