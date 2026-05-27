{ config, inputs, lib, pkgs, ... }:
{
  ##############################################################################
  # 完整说明
  ##############################################################################
  options.services.hermes-agent-dashboard = {

    enable = lib.mkEnableOption "Hermes Agent Web Dashboard";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "Hermes 包路径";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "绑定 IP非 127.0.0.1 需开启 insecure";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9119;
      description = "监听端口";
    };

    insecure = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "允许非 localhost 绑定警告：会暴露 API 密钥";
    };

    tui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "启用浏览器内嵌终端追加 --tui 及环境变量";
    };

    skipBuild = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "跳过前端 npm 构建，使用预构建文件追加 --skip-build";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "hermes";
      description = "运行用户";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "hermes";
      description = "运行用户组";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/hermes";
      description = "服务 $HOME 目录数据实际存于 <dataDir>/.hermes/";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "环境变量文件路径 (如密钥)由 systemd 加载，不入 nix store";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "额外环境变量值为空字符串 \"\" 会被自动过滤";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "开放防火墙端口需同时开启 insecure";
    };
  };

  ##############################################################################
  # 示例 1：最简本地开发配置（默认值即可运行）
  ##############################################################################
  # 仅绑定 127.0.0.1:9119，无需开放防火墙，适合单机开发者使用
  services.hermes-agent-dashboard = {
    enable = true;
    # package     = pkgs.hermes-agent;       # 默认值
    # host        = "127.0.0.1";             # 默认值
    # port        = 9119;                    # 默认值
    # insecure    = false;                   # 默认值
    # tui         = false;                   # 默认值
    # skipBuild   = false;                   # 默认值
    # user        = "hermes";                # 默认值
    # group       = "hermes";                # 默认值
    # dataDir     = "/var/lib/hermes";       # 默认值
  };


  ##############################################################################
  # 示例 2：启用浏览器内聊天 TUI + 调试日志
  ##############################################################################
  # 打开嵌入式终端聊天标签页，并将日志级别设为 debug
  services.hermes-agent-dashboard = {
    enable = true;
    tui = true;                               # 启用浏览器内 Chat 标签
    extraEnvironment = {
      HERMES_LOG_LEVEL = "debug";
      # HERMES_DASHBOARD_TUI 已由 tui = true 自动设为 "1"，无需重复
    };
  };


  ##############################################################################
  # 示例 3：通过 environmentFile 注入 API 密钥等敏感信息
  ##############################################################################
  # 密钥可由 sops-nix / agenix 等秘密管理工具生成到 /run/secrets/ 下，
  # systemd 启动前加载，不会出现在 /nix/store 中
  services.hermes-agent-dashboard = {
    enable = true;
    tui = true;
    environmentFile = "/run/secrets/hermes-extra.env";
  };
  # /run/secrets/hermes-extra.env 内容示例：
  #   OPENAI_API_KEY=sk-XXXXXXXXXXXXXXXXXXXXXXXX
  #   ANTHROPIC_API_KEY=sk-ant-XXXXXXXXXXXXXXXXXX
  #   HERMES_PROVIDER=openai


  ##############################################################################
  # 示例 4：局域网 / 远程访问（insecure 模式）
  ##############################################################################
  # 绑定 0.0.0.0 并开放防火墙端口，使局域网其它机器可访问仪表盘
  # ⚠️  警告：API 密钥会在网络上明文传输，务必在可信内网中使用，
  #          生产环境应前置反向代理（Nginx/Caddy）+ TLS
  services.hermes-agent-dashboard = {
    enable = true;
    host = "0.0.0.0";
    port = 9119;
    insecure = true;                          # 必须显式开启才能绑定非 localhost
    openFirewall = true;                      # 自动开放 TCP 9119
    tui = true;
  };

  ##############################################################################
  # 示例 5：CI / 无 npm 环境 — 使用预构建前端
  ##############################################################################
  # 在 CI 或无 Node.js 的环境中，先用 `cd web && npm run build` 构建前端，
  # 然后设置 skipBuild = true 跳过运行时构建步骤
  services.hermes-agent-dashboard = {
    enable = true;
    skipBuild = true;
    extraEnvironment = {
      HERMES_LOG_LEVEL = "warn";
    };
  };

  ##############################################################################
  # 示例 6：非默认数据目录 + 手动预置配置文件
  ##############################################################################
  # 将数据存放到独立磁盘，并在启用服务前预置 config.yaml 和 .env
  services.hermes-agent-dashboard = {
    enable = true;
    dataDir = "/mnt/data/hermes";
  };

  # 通过 systemd tmpfiles 规则在首次启动前预置配置（仅当文件不存在时写入）
  systemd.tmpfiles.rules = [
    "d /mnt/data/hermes/.hermes 0750 hermes hermes -"
    "f /mnt/data/hermes/.hermes/config.yaml 0640 hermes hermes - "
    + builtins.toJSON {
      provider = "openai";
      model = "gpt-4o";
      temperature = 0.7;
      max_tokens = 4096;
    }
  ];
}
