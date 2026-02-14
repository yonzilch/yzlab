_: {
  boot = {
    kernelParams = [
      # 禁用透明大页 (THP)
      "transparent_hugepage=never"
    ];
    kernel.sysctl = {
      # 内存超额分配
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

  virtualisation.oci-containers.containers."valkey" = {
    image = "valkey/valkey:latest";
    volumes = [
      "valkey:/data"
    ];
    ports = [
      "127.0.0.1:6379:6379"
    ];
  };
}
