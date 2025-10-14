_: {
  environment.etc."sonic.cfg" = {
    mode = "0644";
    text = ''
      # Sonic
      # Configuration file (integration tests)

      [server]

      log_level = "warn"

      [channel]

      inet = "127.0.0.1:1491"
      auth_password = "password:test"

      [channel.search]

      [store]

      [store.kv]
      [store.kv.pool]
      [store.kv.database]

      [store.fst]
      [store.fst.pool]
      [store.fst.graph]
    '';
  };

  virtualisation.oci-containers.containers."sonic" = {
    image = "valeriansaliou/sonic:latest";
    environment = {
      "SEARCH_BACKEND_PASSWORD" = "SomeSecretPassword";
    };
    ports = [
      "127.0.0.1:1491:1491"
    ];
    volumes = [
      "sonic:/var/lib/sonic/store:rw"
      "/etc/sonic.cfg:/etc/sonic.cfg:ro"
    ];
  };
}
