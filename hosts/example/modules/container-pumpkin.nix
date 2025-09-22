_: {
  environment.etc = {
    "pumpkin/config/configuration.toml" = {
      text = ''
        server_address = "0.0.0.0:25565"
        seed = ""
        max_players = 100000
        view_distance = 10
        simulation_distance = 10
        default_difficulty = "Hard"
        op_permission_level = 4
        allow_nether = true
        hardcore = false
        online_mode = false
        encryption = true
        motd = "A blazingly fast Pumpkin server!"
        tps = 20.0
        default_gamemode = "Survival"
        force_gamemode = false
        scrub_ips = true
        use_favicon = true
        favicon_path = "icon.png"
        default_level_name = "world"
        allow_chat_reports = false
        white_list = false
        enforce_whitelist = false
      '';
    };
    "pumpkin/config/features.toml" = {
      text = ''
        [logging]
        enabled = true
        threads = true
        color = true
        timestamp = true

        [resource_pack]
        enabled = false
        url = ""
        sha1 = ""
        prompt_message = ""
        force = false

        [chunk]
        format = "Anvil"
        write_in_place = false

        [chunk.compression]
        algorithm = "LZ4"
        level = 6

        [networking.authentication]
        enabled = false
        connect_timeout = 5000
        read_timeout = 5000
        prevent_proxy_connections = false

        [networking.authentication.player_profile]
        allow_banned_players = false
        allowed_actions = ["FORCED_NAME_CHANGE", "USING_BANNED_SKIN"]

        [networking.authentication.textures]
        enabled = false
        allowed_url_schemes = ["http", "https"]
        allowed_url_domains = [".minecraft.net", ".mojang.com"]

        [networking.authentication.textures.types]
        skin = true
        cape = true
        elytra = true

        [networking.query]
        enabled = false

        [networking.rcon]
        enabled = false
        address = "0.0.0.0:25575"
        password = ""
        max_connections = 0

        [networking.rcon.logging]
        logged_successfully = true
        wrong_password = true
        commands = true
        quit = true

        [networking.proxy]
        enabled = false

        [networking.proxy.velocity]
        enabled = false
        secret = ""

        [networking.proxy.bungeecord]
        enabled = false

        [networking.packet_compression]
        enabled = true
        threshold = 256
        level = 4

        [networking.lan_broadcast]
        enabled = false

        [commands]
        use_console = true
        use_tty = true
        log_console = true
        default_op_level = 0

        [chat]
        format = "<{DISPLAYNAME}> {MESSAGE}"

        [pvp]
        enabled = true
        hurt_animation = true
        protect_creative = true
        knockback = true
        swing = true

        [server_links]
        enabled = true
        bug_report = "https://github.com/Pumpkin-MC/Pumpkin/issues"
        support = ""
        status = ""
        feedback = ""
        community = ""
        website = ""
        forums = ""
        news = ""
        announcements = ""

        [server_links.custom]

        [player_data]
        save_player_data = true
        save_player_cron_interval = 300

        [fun]
        april_fools = true
      '';
    };
  };

  virtualisation.oci-containers.containers."pumpkin" = {
    image = "ghcr.io/pumpkin-mc/pumpkin:master";
    volumes = [
      "/etc/pumpkin/config/configuration.toml:/pumpkin/config/configuration.toml"
      "/etc/pumpkin/config/features.toml:/pumpkin/config/features.toml"
      "pumpkin:/pumpkin"
    ];
    ports = [
      "25565:25565/tcp"
    ];
  };
}
