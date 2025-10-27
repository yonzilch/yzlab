_: {
  virtualisation.oci-containers.containers."zipline" = {
    image = "ghcr.io/diced/zipline:latest";
    environment = {
      # see https://zipline.diced.sh/docs/config/core
      CORE_SECRET = "xxxxxx"; # could be generate by command: openssl rand -base64 42 | tr -dc A-Za-z0-9 | cut -c -32 | tr -d '\n'
      DATABASE_URL = "xxxxxx";
    };
    ports = [
      "127.0.0.1:31342:3000"
    ];
    volumes = [
      "zipline:/zipline:rw"
    ];
  };
}
