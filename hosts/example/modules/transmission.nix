_: {
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    openRPCPort = false;

    user = "transmission";
    group = "transmission";

    settings = {
      download-dir = "/var/lib/transmission/Downloads";
      incomplete-dir = "/var/lib/transmission/.incomplete";
      incomplete-dir-enabled = true;

      # rpc 配置
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      rpc-authentication-required = false;
      # rpc-username = "admin";
      # rpc-password = "xxxxxx";
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,::1";
      rpc-host-whitelist-enabled = false;

      # 端口配置
      peer-port = 51413;
      peer-port-random-on-start = false;
      port-forwarding-enabled = true;

      # 速度限制 (单位: KB/s)
      speed-limit-down-enabled = false;
      speed-limit-down = 5000;
      speed-limit-up-enabled = false;
      speed-limit-up = 1000;

      # 上传比例限制
      ratio-limit-enabled = false;
      ratio-limit = 2.0;

      # DHT 和 PEX
      dht-enabled = true;
      pex-enabled = true;
      lpd-enabled = false;

      # 启用 uTP
      utp-enabled = true;

      # 加密
      encryption = 1; # 0=off, 1=preferred, 2=required

      # 其他设置
      umask = 2; # 文件权限: 775
      message-level = 1; # 0=None, 1=Error, 2=Info, 3=Debug

      # 连接数限制
      peer-limit-global = 200;
      peer-limit-per-torrent = 50;

      # webHome = "pkgs.flood-for-transmission";
    };
  };

  # 确保下载目录存在并设置正确权限
  systemd.tmpfiles.rules = [
    "d /var/lib/transmission 0755 www www -"
    "d /var/lib/transmission/Downloads 0755 www www -"
    "d /var/lib/transmission/.incomplete 0755 www www -"
  ];
}
