_: {
  # use command
  # podman exec -it postgres sh -c "su postgres"
  # to connect postgres
  virtualisation.oci-containers.containers."postgres" = {
    pull = "newer";
    image = "postgres:18-alpine";
    volumes = [
      "postgres:/var/lib/postgresql/data:rw"
    ];
    ports = [
      "127.0.0.1:5432:5432"
    ];
  };
}
