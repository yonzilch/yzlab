_: {
  virtualisation.oci-containers.containers."rustpad" = {
    image = "ekzhang/rustpad:latest";
    environment = {
      "EXPIRY_DAYS" = "1";
      # "SQLITE_URI" = "";
      # "PORT" = "3030";
      # "RUST_LOG" = "data=debug,hardware=debug";
    };
    ports = [
      "127.0.0.1:3030:3030"
    ];
  };
}
