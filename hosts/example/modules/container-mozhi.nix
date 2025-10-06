_: {
  virtualisation.oci-containers.containers."mozhi" = {
    image = "codeberg.org/aryak/mozhi:latest";
    ports = [
      "127.0.0.1:13000:3000"
    ];
  };
}
