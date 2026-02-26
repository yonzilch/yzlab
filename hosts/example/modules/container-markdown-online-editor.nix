_: {
  virtualisation.oci-containers.containers."markdown-online-editor" = {
    image = "nicejade/markdown-online-editor:latest";
    ports = [
      "127.0.0.1:8866:80"
    ];
  };
}
