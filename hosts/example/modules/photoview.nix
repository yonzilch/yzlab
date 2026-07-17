{ lib, ... }:
{
  services.photoview = {
    enable = true;
    user = "www";
    database.type = "sqlite";
    host = "127.0.0.1";
    port = 39013;
    dataDir = "/home/www/photoview/dataDir";
    mediaPath = "/home/www/syncthing/photos";
    settings = {
      disableFaceRecognition = true;
      disableRawProcessing = true;
      disableVideoEncoding = true;
    };
  };

  systemd.services.photoview.serviceConfig = {
    ProtectHome = lib.mkForce false;
  };

  systemd.tmpfiles.rules = [
    "d /home/www/photoview          0755 www www - -"
    "d /home/www/photoview/dataDir  0755 www www - -"
    "d /home/www/syncthing/photos   0755 www www - -"
  ];
}
