{...}: let
  apiKey = "livekit";
  apiSecret = "xxxxxx"; # use command `openssl-rand-hex-32` to generate
  domain = "livekit.example.com";
in {
  environment.etc."livekit/config.yaml".text = ''
    port: 7880
    bind_addresses:
      - "0.0.0.0"

    rtc:
      udp_port: 7881
      tcp_port: 7882
      use_external_ip: true

    keys:
      ${apiKey}: ${apiSecret}

    turn:
      enabled: true
      udp_port: 3478
      relay_range_start: 50300
      relay_range_end: 65535
      domain: ${domain}

    logging:
      level: info
      json: false
  '';

  networking.firewall = {
    allowedTCPPorts = [
      7882 # RTC TCP
    ];
    allowedUDPPorts = [
      7881 # RTC UDP
      3478 # TURN UDP
    ];
    allowedUDPPortRanges = [
      {
        from = 50300;
        to = 65535;
      } # TURN relay
    ];
  };

  virtualisation.oci-containers.containers = {
    "livekit" = {
      image = "livekit/livekit-server:latest";
      cmd = [
        "--config"
        "/etc/livekit/config.yaml"
      ];
      ports = [
        "127.0.0.1:7880:7880" # HTTP API，需反代
        "7881:7881/udp" # RTC UDP，公网直连
        "7882:7882" # RTC TCP，公网直连
        "3478:3478/udp" # TURN UDP
        "50300-65535:50300-65535/udp" # TURN relay
      ];
      volumes = [
        "/etc/livekit/config.yaml:/etc/livekit/config.yaml:ro"
      ];
      extraOptions = ["--network=host"];
    };

    "lk-jwt" = {
      image = "ghcr.io/element-hq/lk-jwt-service:latest";
      pull = "newer";

      environment = {
        LIVEKIT_URL = "ws://127.0.0.1:7880";
        LIVEKIT_KEY = "${apiKey}";
        LIVEKIT_SECRET = "${apiSecret}";
        LIVEKIT_FULL_ACCESS_HOMESERVERS = "matrix.example.com"; # For Matrix server
        LIVEKIT_JWT_BINDj = "8080";
      };

      ports = [
        "127.0.0.1:8080:8080"
      ];
      extraOptions = ["--network=host"];
    };
  };
}
