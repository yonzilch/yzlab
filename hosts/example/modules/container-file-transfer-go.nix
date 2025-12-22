_: {
  virtualisation.oci-containers.containers."file-transfer-go" = {
    pull = "newer";
    image = "matrixseven/file-transfer-go:latest";
    ports = [
      "127.0.0.1:37592:8080"
    ];
  };
}
