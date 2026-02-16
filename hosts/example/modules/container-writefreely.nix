{pkgs, ...}: {
  environment.etc."writefreely/config.ini" = {
    mode = "0755";
    text = ''
      [server]
      hidden_host =
      port = 8080
      bind = 0.0.0.0
      tls_cert_path =
      tls_key_path =
      autocert = false
      templates_parent_dir = /go
      static_parent_dir = /go
      pages_parent_dir = /go
      keys_parent_dir = /go

      [database]
      type = mysql
      username = writefreely
      password = xxxxxx
      database = writefreely
      host = mariadb
      port = 3306
      tls = false

      [app]
      site_name = Example WriteFreely
      site_description = A place to write
      host = https://write.example.com
      theme = write
      editor = pad
      disable_js = false
      webfonts = true
      landing = /
      simple_nav = false
      federation = true
      public_stats = true
      private = false
      local_timeline = true
      user_invites = admin
      default_visibility = public
      max_blogs = 100
      disable_password_auth = true
      open_registration = true

      [oauth.generic]
      client_id = xxxxxx
      client_secret = xxxxxx
      host = https://auth.example.com
      display_name = Example SSO
      callback_proxy =
      callback_proxy_api =
      token_endpoint = /oidc/token
      inspect_endpoint = /oidc/me
      auth_endpoint = /oidc/auth
      scope = openid email profile
      allow_disconnect = false
      map_user_id = sub
      map_username = preferred_username
      map_display_name = name
      map_email = email
    '';
  };

  # To initialize the database, run:
  # podman exec -it writefreely /go/cmd/writefreely/writefreely db init

  virtualisation.oci-containers.containers."writefreely" = {
    image = "docker.io/writeas/writefreely:latest";
    volumes = [
      "writefreely:/go:rw"
      "/etc/writefreely/config.ini:/go/config.ini:rw"
    ];
    ports = [
      "127.0.0.1:49012:8080"
    ];
  };

  systemd.services.create-mariadb-db-for-writefreely = {
    wantedBy = ["multi-user.target"];
    after = ["podman-mariadb.service"];
    description = "Initialize MariaDB database for WriteFreely";
    path = with pkgs; [zfs];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = ''
        ${pkgs.podman}/bin/podman exec -i mariadb \
        mariadb -u root \
        -e "CREATE DATABASE IF NOT EXISTS writefreely CHARACTER SET latin1 COLLATE latin1_swedish_ci;" \
        -e "CREATE USER IF NOT EXISTS 'writefreely'@'%' IDENTIFIED BY 'xxxxxx';" \
        -e "GRANT ALL PRIVILEGES ON writefreely.* TO 'writefreely'@'%';" \
        -e "FLUSH PRIVILEGES;"
      '';
    };
  };
}
