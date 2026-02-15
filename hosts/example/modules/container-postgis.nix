_: {
  # use command
  # podman exec -it postgis sh -c "su postgres"
  # to connect postgres
  virtualisation.oci-containers.containers."postgis" = {
    pull = "newer";
    image = "postgis/postgis:17-3.6-alpine";
    environment = {
      "POSTGRES_PASSWORD" = "xxxxxx";
    };
    volumes = [
      "postgis:/var/lib/postgresql/data:rw"
    ];
    ports = [
      "127.0.0.1:25432:5432"
    ];
    extraOptions = [
      "--health-cmd=pg_isready -U postgres || exit 1"
      "--health-interval=10s"
      "--health-timeout=5s"
      "--health-retries=3"
      "--health-start-period=30s"
    ];
  };
}
