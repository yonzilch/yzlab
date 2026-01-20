{
  config,
  pkgs,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    extensions = with pkgs.postgresql_18.pkgs; [
      pgroonga
    ];
    enableTCPIP = true;
    ensureDatabases = ["xxxxxx"];
    ensureUsers = [
      {
        name = "xxxxxx";
        ensureDBOwnership = true;
      }
    ];

    # Tune performance (Specifically for 6GB RAM)
    settings = {
      shared_preload_libraries = "pgroonga";

      shared_buffers = "1536MB";
      effective_cache_size = "3GB";
      maintenance_work_mem = "256MB";
      work_mem = "16MB";
      wal_buffers = "16MB";

      checkpoint_completion_target = 0.9;
      max_wal_size = "2GB";
      min_wal_size = "512MB";

      max_connections = 100;

      random_page_cost = 1.1;
      effective_io_concurrency = 200;

      log_min_duration_statement = 1000;
      log_line_prefix = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ";

      log_destination = "stderr";
      logging_collector = true;

      autovacuum_max_workers = 2;
      autovacuum_naptime = "1min";

      temp_buffers = "8MB";
    };
    authentication = pkgs.lib.mkOverride 10 ''
      local   all             postgres                                peer
      local   all             all                                     peer

      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';

    initialScript = pkgs.writeText "init.sql" ''
      ALTER USER postgres WITH PASSWORD 'H61YOBSBom24tnWiJ1YsAyLDM8TfVikh';
    '';
  };

  systemd.services.postgresql-pgroonga-init = {
    description = "Initialize PGroonga extension for openlist database";
    after = ["postgresql.service"];
    requires = ["postgresql.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };

    script = ''
      for i in {1..30}; do
        if ${config.services.postgresql.package}/bin/psql -d openlist -c "SELECT 1" > /dev/null 2>&1; then
          break
        fi
        echo "Waiting for openlist database to be created... ($i/30)"
        sleep 1
      done
      ${config.services.postgresql.package}/bin/psql -d openlist -c "CREATE EXTENSION IF NOT EXISTS pgroonga;" || true
    '';
  };
}
