_: {
  virtualisation.oci-containers.containers."homebox" = {
    pull = "newer";
    image = "ghcr.io/sysadminsmedia/homebox:latest";
    environment = { # see https://homebox.software/en/configure
      "HBOX_LOG_LEVEL" = "info";
      "HBOX_LOG_FORMAT" = "text";
      "HBOX_WEB_MAX_FILE_UPLOAD" = "10";
      "HBOX_OPTIONS_ALLOW_ANALYTICS" = "false";
      "HBOX_OPTIONS_ALLOW_REGISTRATION" = "true";
    };
    volumes = [
      "homebox:/data:rw"
    ];
    ports = [
      "127.0.0.1:7745:7745"
    ];
  };
}
