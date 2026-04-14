_: {
  virtualisation.oci-containers.containers."talebook" = {
    image = "talebook/talebook";
    pull = "newer";
    environment = {
      "PUID" = "1000";
      "PGID" = "1000";
      "TZ" = "Asia/Singapore";
    };
    ports = [
      "127.0.0.1:59180:80/tcp"
    ];
    volumes = [
      "talebook:/data"
    ];
  };
}
