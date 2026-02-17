_: {
  virtualisation.oci-containers.containers."typesense" = {
    image = "typesense/typesense:30.1";
    pull = "newer";
    cmd = [
      "--data-dir"
      "/data"
      "--api-key=xxxxxx"
    ];
    volumes = ["typesense:/data"];
    environment.GLOG_minloglevel = "2";
    ports = ["127.0.0.1:8108:8108"];
  };
}
