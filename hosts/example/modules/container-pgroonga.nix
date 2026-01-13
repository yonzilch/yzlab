_: {
  # use command
  # podman exec -it pgroonga sh -c "su postgres"
  # to connect pgroonga
  virtualisation.oci-containers.containers."pgroonga" = {
    pull = "newer";
    image = "groonga/pgroonga:4.0.5-alpine-18-slim";
    environment = {
      "POSTGRES_PASSWORD" = "xxxxxx";

      # ===== 性能优化参数 =====
      # 以 8GB RAM 为例
      # 共享内存缓冲区 (建议: 25% of RAM)
      # "POSTGRES_SHARED_BUFFERS" = "2GB";

      # 有效缓存大小 (建议: 50% of RAM)
      # "POSTGRES_EFFECTIVE_CACHE_SIZE" = "4GB";

      # 维护工作内存 (建议: 5% of RAM)
      # "POSTGRES_MAINTENANCE_WORK_MEM" = "400MB";

      # 每个连接的工作内存 (建议: RAM / max_connections / 4)
      # "POSTGRES_WORK_MEM" = "16MB";

      # WAL 缓冲区
      "POSTGRES_WAL_BUFFERS" = "16MB";
      "POSTGRES_MAX_WAL_SIZE" = "4GB";
      "POSTGRES_MIN_WAL_SIZE" = "1GB";

      # 检查点配置
      "POSTGRES_CHECKPOINT_COMPLETION_TARGET" = "0.9";

      # 并发连接数 (根据应用需求调整)
      "POSTGRES_MAX_CONNECTIONS" = "200";

      # 随机页面代价 (SSD 优化)
      "POSTGRES_RANDOM_PAGE_COST" = "1.1";

      # 有效 I/O 并发度 (NVMe SSD)
      "POSTGRES_EFFECTIVE_IO_CONCURRENCY" = "200";

      # 日志配置
      "POSTGRES_LOG_MIN_DURATION_STATEMENT" = "1000"; # 记录慢查询 (>1秒)
      "POSTGRES_LOG_LINE_PREFIX" = "%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ";
    };
    volumes = [
      "pgroonga:/var/lib/postgresql/data:rw"
    ];
    ports = [
      "127.0.0.1:5432:5432"
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
