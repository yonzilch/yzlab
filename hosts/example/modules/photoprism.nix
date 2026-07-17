{ lib, ... }:
{
  services.photoprism = {
    enable = true;

    user = "www";
    address = "127.0.0.1";
    port = 2342;

    originalsPath = "/home/www/photoprism/originalsPath";
    storagePath = "/home/www/photoprism/storagePath";

    settings = {
      PHOTOPRISM_ADMIN_USER = "foobar";
      PHOTOPRISM_ADMIN_USERNAME = "foobar";
      PHOTOPRISM_ADMIN_PASSWORD = "xxxxxx";

      PHOTOPRISM_DATABASE_DRIVER = "sqlite";

      PHOTOPRISM_HTTP_HOST = "0.0.0.0";
      PHOTOPRISM_HTTP_PORT = "2342";

      PHOTOPRISM_SITE_URL = "https://image.example.com/";
      PHOTOPRISM_SITE_CAPTION = "";

      PHOTOPRISM_APP_NAME = "";
      PHOTOPRISM_APP_COLOR = "#A1A1A1";
      PHOTOPRISM_WALLPAPER_URI = "";

      PHOTOPRISM_READONLY = "false";
      PHOTOPRISM_UPLOAD_NSFW = "true";
      PHOTOPRISM_DETECT_NSFW = "false";

      PHOTOPRISM_DISABLE_TLS = "true";
      PHOTOPRISM_DISABLE_BACKUPS = "true";
      PHOTOPRISM_DISABLE_CLASSIFICATION = "true";
      PHOTOPRISM_DISABLE_CHOWN = "false";
      PHOTOPRISM_DISABLE_FACES = "true";
      PHOTOPRISM_DISABLE_TENSORFLOW = "true";
      PHOTOPRISM_DISABLE_WEBDAV = "false";

      PHOTOPRISM_EXPERIMENTAL = "false";
      PHOTOPRISM_INDEX_SCHEDULE = "@every 1h";
      PHOTOPRISM_LOG_LEVEL = "info";
      PHOTOPRISM_USAGE_INFO = "true";
    };
  };

  systemd.services.photoprism.serviceConfig = {
    ProtectHome = lib.mkForce false;
  };

  systemd.tmpfiles.rules = [
    "d /home/www/photoprism                0755 www www - -"
    "d /home/www/photoprism/originalsPath  0755 www www - -"
    "d /home/www/photoprism/storagePath    0755 www www - -"
  ];
}
