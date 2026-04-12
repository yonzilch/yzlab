_: {
  virtualisation.oci-containers.containers."opencloud" = {
    image = "opencloudeu/opencloud-rolling:latest";
    entrypoint = "/bin/sh";
    cmd = [
      "-c"
      "opencloud init || true; opencloud server"
    ];
    environment = {
      # 公开访问 URL，容器内部也用这个做 OIDC 自调用
      "OC_URL" = "https://cloud.example.com";

      # 反代场景：禁用容器内 TLS
      "PROXY_TLS" = "false";
      "PROXY_HTTP_ADDR" = "0.0.0.0:9200";
      "OC_INSECURE" = "false";

      "OC_LOG_LEVEL" = "warn";
      "OC_LOG_COLOR" = "false";
      "OC_LOG_PRETTY" = "false";

      # 初始管理员密码
      "IDM_ADMIN_PASSWORD" = "xxxxxx";

      # WebDAV 客户端 basic auth 支持（可选）
      "PROXY_ENABLE_BASIC_AUTH" = "true";

      # 上传大文件限制
      "FRONTEND_ARCHIVER_MAX_SIZE" = "10000000000";

      # 不创建演示用户
      "IDM_CREATE_DEMO_USERS" = "false";
    };
    volumes = [
      "opencloud_config:/etc/opencloud"
      "opencloud_data:/var/lib/opencloud"
    ];
    ports = [
      "127.0.0.1:49200:9200"
    ];
    # 关键：让容器能解析自身域名，否则 OIDC 内部调用会失败
    # 将 cloud.example.com 指向宿主机 IP，由 Traefik 转发回容器
    extraOptions = [
      "--add-host=cloud.example.com:host-gateway"
    ];
  };
}
