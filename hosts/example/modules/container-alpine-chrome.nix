_: {
  virtualisation.oci-containers.containers."alpine-chrome" = {
    pull = "newer";
    image = "gcr.io/zenika-hub/alpine-chrome:latest";
    cmd = [
      "--no-sandbox"
      "--disable-gpu"
      "--disable-dev-shm-usage"
      "--remote-debugging-address=0.0.0.0"
      "--remote-debugging-port=9222"
      "--hide-scrollbars"
    ];
    ports = [
      "127.0.0.1:9222:9222"
    ];
  };
}
