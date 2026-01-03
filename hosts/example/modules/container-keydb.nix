_: {
  boot = {
    kernelParams = [
      # 禁用透明大页 (THP) - KeyDB 官方建议
      "transparent_hugepage=never"
    ];
    kernel.sysctl = {
      # 内存超额分配 (KeyDB RDB/AOF 持久化必需)
      "vm.overcommit_memory" = 1;

      # 减少 swap 使用 (内存数据库应尽量留在 RAM)
      "vm.swappiness" = 1;

      # TCP 连接队列优化 (高并发场景)
      "net.core.somaxconn" = 65535;
      "net.ipv4.tcp_max_syn_backlog" = 8192;

      # TCP 快速回收和重用 (提高连接复用率)
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 30;
    };
  };

  virtualisation.oci-containers.containers."keydb" = {
    pull = "newer";
    image = "eqalpha/keydb:latest";

    volumes = [
      "keydb:/data:rw"
    ];

    ports = [
      "127.0.0.1:6379:6379"
    ];

    environment = {
      # ===== 多线程配置 =====
      "SERVER_THREADS" = "4"; # 增加到 4 线程以充分利用 CPU

      # ===== I/O 多线程 (关键优化) =====
      "IO_THREADS" = "3"; # 启用 3 个 I/O 线程处理网络
      "IO_THREADS_DO_READS" = "yes"; # 读操作也使用 I/O 线程

      # ===== 持久化配置 =====
      # RDB 快照策略: 900秒内1个写入 OR 300秒内10个 OR 60秒内10000个
      "SAVE" = "900 1 300 10 60 10000";
      "APPENDONLY" = "yes"; # 启用 AOF 日志
      "APPENDFSYNC" = "everysec"; # 每秒同步一次 (性能与安全平衡)

      # ===== 内存管理 =====
      "MAXMEMORY" = "2gb"; # 最大内存限制
      "MAXMEMORY_POLICY" = "allkeys-lru"; # LRU 淘汰策略

      # ===== 网络优化 =====
      "TCP_BACKLOG" = "65535"; # 匹配 somaxconn
      "TIMEOUT" = "300"; # 客户端空闲超时 (秒)
      "TCP_KEEPALIVE" = "300"; # TCP keepalive 探测

      # ===== 性能调优 =====
      "LAZYFREE_LAZY_EVICTION" = "yes"; # 异步释放内存
      "LAZYFREE_LAZY_EXPIRE" = "yes"; # 异步过期删除
      "LAZYFREE_LAZY_SERVER_DEL" = "yes"; # 异步隐式删除
      "REPLICA_LAZY_FLUSH" = "yes"; # 异步清空数据库

      # ===== 日志配置 =====
      "LOGLEVEL" = "notice"; # 生产环境推荐
      "SYSLOG_ENABLED" = "no";
    };

    extraOptions = [
      "--health-cmd=keydb-cli ping"
      "--health-interval=10s"
      "--health-timeout=5s"
      "--health-retries=3"
    ];
  };
}
