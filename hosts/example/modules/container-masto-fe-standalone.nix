_: {
  virtualisation.oci-containers.containers."masto-fe-standalone" = {
    image = "docker.io/superseriousbusiness/masto-fe-standalone:next";
    ports = [
      "127.0.0.1:48931:80"
    ];
  };
}
