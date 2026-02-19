_: {
  virtualisation.oci-containers.containers."gotenberg" = {
    image = "docker.io/gotenberg/gotenberg:latest";
    pull = "newer";

    cmd = [
      "gotenberg"
      "--chromium-disable-javascript=true"
      "--chromium-allow-list=file:///tmp/.*"
    ];

    ports = [
      "127.0.0.1:51492:3000"
    ];
  };
}
