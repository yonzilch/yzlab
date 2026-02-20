_: {
  # To connect to PostgreSQL inside the container, use:
  # podman exec -it pgvector sh -c "su postgres"

  virtualisation.oci-containers.containers."pgvector" = {
    pull = "newer";
    image = "pgvector/pgvector:0.8.1-pg18-trixie";

    environment = {
      POSTGRES_PASSWORD = "xxxxxx";

      # ── Performance tuning parameters (16GB RAM as example) ───────────────────────────────
      # Shared buffers (recommended: ~25% of system RAM)
      POSTGRES_SHARED_BUFFERS = "4GB";

      # Effective cache size (recommended: ~50-75% of system RAM)
      POSTGRES_EFFECTIVE_CACHE_SIZE = "8GB";

      # Maintenance work memory (recommended: ~5% of system RAM)
      POSTGRES_MAINTENANCE_WORK_MEM = "800MB";

      # Work memory per operation / connection
      # (rough rule: RAM / max_connections / 3–4)
      POSTGRES_WORK_MEM = "32MB";

      # WAL buffers
      POSTGRES_WAL_BUFFERS = "16MB";

      # Checkpoint tuning
      POSTGRES_CHECKPOINT_COMPLETION_TARGET = "0.9";
      POSTGRES_MAX_WAL_SIZE = "4GB";
      POSTGRES_MIN_WAL_SIZE = "1GB";

      # Maximum concurrent connections
      # Adjust based on your actual workload and available RAM
      POSTGRES_MAX_CONNECTIONS = "200";

      # SSD / NVMe optimizations
      POSTGRES_RANDOM_PAGE_COST = "1.1";
      POSTGRES_EFFECTIVE_IO_CONCURRENCY = "200";

      # Logging (slow query log threshold > 1 second)
      POSTGRES_LOG_MIN_DURATION_STATEMENT = "1000";

      # Detailed log prefix (time, pid, user, db, app name, client host)
      POSTGRES_LOG_LINE_PREFIX = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ";
    };

    volumes = [
      "pgvector:/var/lib/postgresql:rw"
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
