_: {
  virtualisation.oci-containers.containers."trilium" = {
    image = "triliumnext/trilium:latest";
    volumes = [
      "trilium:/home/node/trilium-data:rw"
    ];
    ports = [
      "127.0.0.1:59436:8080"
    ];
  };
}
