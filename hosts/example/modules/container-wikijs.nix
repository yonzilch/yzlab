{ pkgs, ... }:
{
  virtualisation.oci-containers.containers."wikijs" = {
    image = "requarks/wiki:latest";
    environment = {
      DB_TYPE = "postgres";
      DB_HOST = "postgres";
      DB_PORT = "5432";
      DB_USER = "wikijs";
      DB_PASS = "xxxxxx";
      DB_NAME = "wikijs";
    };
    ports = [
      "127.0.0.1:39018:3000"
    ];
    volumes = [
      "wiki-js_data:/data:rw"
      "wiki-js_content:/wiki/data/content:rw"
    ];
    dependsOn = [ "postgres" ];
  };

  systemd.services.create-pg-db-for-wikijs = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-postgres.service" ];
    description = "Initialize PostgreSQL database and extensions for wikijs";
    path = with pkgs; [ zfs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SuccessExitStatus = "0 1 3";
    };

    script = ''
      echo "=== Creating Wiki.js PostgreSQL user and database ==="

      ${pkgs.podman}/bin/podman exec -i postgres psql -U postgres -v ON_ERROR_STOP=1 <<'EOF'
      -- 创建角色（如果已存在则跳过）
      DO $$
      BEGIN
        CREATE ROLE wikijs WITH LOGIN PASSWORD 'xxxxxx';
      EXCEPTION WHEN duplicate_object THEN
        RAISE NOTICE 'Role wikijs already exists';
      END $$;

      -- 创建数据库
      CREATE DATABASE wikijs WITH
        ENCODING='UTF8'
        LC_COLLATE='C'
        LC_CTYPE='C'
        TEMPLATE=template0
        OWNER=wikijs;

      -- 切换到 wikijs 数据库并创建所需扩展
      \c wikijs

      CREATE EXTENSION IF NOT EXISTS pg_trgm;

      -- 授予必要权限
      GRANT ALL PRIVILEGES ON DATABASE wikijs TO wikijs;
      GRANT ALL ON SCHEMA public TO wikijs;
      -- 设置默认时区
      ALTER TABLE users ALTER COLUMN timezone SET DEFAULT 'Asia/Singapore'::character varying;
      EOF

      echo "=== Wiki.js PostgreSQL setup completed ==="
    '';
  };
}
