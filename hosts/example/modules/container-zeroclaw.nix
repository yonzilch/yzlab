_: {
  virtualisation.oci-containers.containers."zeroclaw" = {
    image = "ghcr.io/zeroclaw-labs/zeroclaw:debian";
    pull = "newer";
    cmd = [ "gateway" ];
    environment = {
    };
    volumes = [
      "zeroclaw_data:/zeroclaw-data:rw"
      # "/etc/zeroclaw-data/.zeroclaw/config.toml:/zeroclaw-data/.zeroclaw/config.toml"
    ];
    ports = [
      "127.0.0.1:42617:42617"
    ];
  };

  # You can use web dashboard to configure zeroclaw
  # environment.etc."zeroclaw-data/.zeroclaw/config.toml" = {
  #   mode = "0755";
  #   text = ''
  #
  #   '';
  # };
}
