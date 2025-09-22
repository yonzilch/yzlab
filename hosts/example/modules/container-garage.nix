_: {
  environment.etc."garage/garage.toml" = {
    mode = "0755";
    text = ''
      metadata_dir = "/var/lib/garage/meta"
      data_dir = "/var/lib/garage/data"
      db_engine = "lmdb"
      replication_mode = "1"
      compression_level = 2
      rpc_bind_addr = "[::]:3901"
      rpc_public_addr = "127.0.0.1:3901"
      rpc_secret = "xxxxxx"
      [s3_api]
      s3_region = "garage"
      api_bind_addr = "[::]:3900"
      root_domain = ".s3.example.com"
      [s3_web]
      bind_addr = "[::]:3902"
      root_domain = "web.example.com"
      index = "index.html"
      [admin]
      api_bind_addr = "[::]:3903"
      admin_token = "xxxxxx"
      metrics_token = "xxxxxx"
    '';
    # About rpc_secret ; admin_token ; metrics_token
    # see https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration ; https://archive.md/zlzBi
  };

  virtualisation.oci-containers.containers."garage" = {
    image = "dxflrs/garage:v1.1.0";
    volumes = [
      "/zhdd/garage:/var/lib/garage/data:rw"
      "garage_meta:/var/lib/garage/meta:rw"
      "/etc/garage/garage.toml:/etc/garage.toml:ro"
    ];
    ports = [
      "127.0.0.1:3900:3900/tcp"
      "127.0.0.1:3901:3901/tcp"
      "127.0.0.1:3902:3902/tcp"
      "127.0.0.1:3903:3903/tcp"
    ];
  };

  virtualisation.oci-containers.containers."garage-webui" = {
    image = "khairul169/garage-webui:1.0.9";
    environment = {
      "API_BASE_URL" = "http://garage:3903";
      "S3_ENDPOINT_URL" = "http://garage:3900";
    };
    volumes = [
      "/etc/garage/garage.toml:/etc/garage.toml:ro"
    ];
    ports = [
      "127.0.0.1:3909:3909/tcp"
    ];
  };
}
