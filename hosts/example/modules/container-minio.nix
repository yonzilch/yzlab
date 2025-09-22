_: {
  virtualisation.oci-containers.containers = {
    "minio" = {
      pull = "newer";
      image = "elestio/minio:latest";
      cmd = [
        "server"
        "--address"
        ":9000"
        "--console-address"
        ":9001"
        "/data"
      ];
      environment = {
        MINIO_ROOT_USER = "foobar";
        MINIO_ROOT_PASSWORD = "xxxxxx";
      };
      volumes = [
        "/mnt/minio:/data"
      ];
      ports = [
        "127.0.0.1:9000:9000"
        "127.0.0.1:9001:9001"
      ];
    };
  };
}
