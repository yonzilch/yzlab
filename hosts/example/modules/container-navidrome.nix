_: {
  virtualisation.oci-containers.containers."navidrome" = {
    image = "deluan/navidrome:latest";
    environment = {
      "ND_BASEURL" = "https://navidrome.example.com";
      "ND_LOGLEVEL" = "info";
      "ND_SCANSCHEDULE" = "1h";
      "ND_DEFAULTTHEME" = "Catppuccin Macchiato";
      "ND_ENABLEINSIGHTSCOLLECTOR" = "false";
      "ND_ENABLEEXTERNALSERVICES" = "false";
      "ND_ENABLESHARING" = "true";
      "ND_ENABLESTARRATING" = "false";
    };
    volumes = [
      "navidrome:/data:rw"
    ];
    ports = [
      "127.0.0.1:4533:4533"
    ];
  };
}
