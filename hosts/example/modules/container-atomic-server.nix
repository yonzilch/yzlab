_: {
  virtualisation.oci-containers.containers."atomic-server" = {
    image = "joepmeneer/atomic-server:latest";
    environment = {
      ATOMIC_SERVER_URL = "https://atomic.example.com";
      ATOMIC_PORT = "9883";
    };
    volumes = [
      "atomic-storage:/atomic-storage:rw"
    ];
    ports = [
      "127.0.0.1:9883:9883"
    ];
  };
}
