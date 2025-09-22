_: let
  LIBRARY-ROOT = "/mnt/kyoo";
  CACHE-ROOT = "kyoo_cache";
  METADATA-ROOT = "kyoo_metadata";
in {
  environment.etc."kyoo-environmentFile" = {
    mode = "0600";
    text = ''
      # vi: ft=sh
      # shellcheck disable=SC2034

      # Useful config options

      # Library root can either be an absolute path or a relative path to your docker-compose.yml file.
      LIBRARY_ROOT=./video
      # You should set this to a path where kyoo can write large amount of data, this is used as a cache by the transcoder.
      # It will automatically be cleaned up on kyoo's startup/shutdown/runtime.
      CACHE_ROOT=/tmp/kyoo_cache
      LIBRARY_LANGUAGES=zh
      # If this is true, kyoo will prefer to download the media in the original language of the item.
      MEDIA_PREFER_ORIGINAL_LANGUAGE=false
      # A pattern (regex) to ignore files.
      LIBRARY_IGNORE_PATTERN=""

      # If this is true, new accounts wont have any permissions before you approve them in your admin dashboard.
      REQUIRE_ACCOUNT_VERIFICATION=true
      # Specify permissions of guest accounts, default is no permissions.
      #UNLOGGED_PERMISSIONS=
      # but you can allow anyone to use your instance without account by doing:
      UNLOGGED_PERMISSIONS=overall.read,overall.play
      # You can specify this to allow guests users to see your collection without behing able to play videos for example:
      # UNLOGGED_PERMISSIONS=overall.read

      # Specify permissions of new accounts.
      DEFAULT_PERMISSIONS=overall.read,overall.play

      # Hardware transcoding (equivalent of --profile docker compose option).
      COMPOSE_PROFILES=cpu # cpu (no hardware acceleration) or vaapi or qsv or nvidia
      # the preset used during transcode. faster means worst quality, you can probably use a slower preset with hwaccels
      # warning: using vaapi hwaccel disable presets (they are not supported).
      GOCODER_PRESET=fast


      # The following value should be set to a random sequence of characters.
      # You MUST change it when installing kyoo (for security)
      # You can input multiple api keys separated by a ,
      KYOO_APIKEYS=xxxxxxxxxxxx

      # Keep those empty to use kyoo's default api key. You can also specify a custom API key if you want.
      # go to https://www.themoviedb.org/settings/api and copy the api key (not the read access token, the api key)
      THEMOVIEDB_APIKEY=
      # go to https://thetvdb.com/api-information/signup and copy the api key
      TVDB_APIKEY=
      # you can also input your subscriber's pin to support TVDB
      TVDB_PIN=


      # The url you can use to reach your kyoo instance. This is used during oidc to redirect users to your instance.
      PUBLIC_URL=http://localhost:8901

      # Use a builtin oidc service (google, discord, trakt, or simkl):
      # When you create a client_id, secret combo you may be asked for a redirect url. You need to specify https://YOUR-PUBLIC-URL/api/auth/logged/YOUR-SERVICE-NAME
      #OIDC_DISCORD_CLIENTID=
      #OIDC_DISCORD_SECRET=
      # Or add your custom one:
      #OIDC_SERVICE_NAME=YourPrettyName
      #OIDC_SERVICE_LOGO=https://url-of-your-logo.com
      #OIDC_SERVICE_CLIENTID=
      #OIDC_SERVICE_SECRET=
      #OIDC_SERVICE_AUTHORIZATION=https://url-of-the-authorization-endpoint-of-the-oidc-service.com/auth
      #OIDC_SERVICE_TOKEN=https://url-of-the-token-endpoint-of-the-oidc-service.com/token
      #OIDC_SERVICE_PROFILE=https://url-of-the-profile-endpoint-of-the-oidc-service.com/userinfo
      #OIDC_SERVICE_SCOPE="the list of scopes space separeted like email identity"
      # Token authentication method as seen in https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication
      # Supported values: ClientSecretBasic (default) or ClientSecretPost
      # If in doubt, leave this empty.
      #OIDC_SERVICE_AUTHMETHOD=ClientSecretBasic
      # on the previous list, service is the internal name of your service, you can add as many as you want.


      # Following options are optional and only useful for debugging.

      # To debug the front end, you can set the following to an external backend
      KYOO_URL=http://kyoo-back:5000/api

      # Database things
      POSTGRES_USER=KyooUser
      POSTGRES_PASSWORD=KyooPassword
      POSTGRES_DB=kyooDB
      POSTGRES_SERVER=postgres
      POSTGRES_PORT=5432

      # Read by the api container to know if it should run meilisearch's migrations/sync
      # and downrabbitmqload missing images. This is a good idea to only have one instance with this on
      # Note: it does not run postgres migrations, use the migration container for that.
      RUN_MIGRATIONS=false

      MEILI_HOST=http://meilisearch:7700
      MEILI_MASTER_KEY=xxxxxx

      RABBITMQ_HOST=rabbitmq
      RABBITMQ_PORT=5672
      RABBITMQ_DEFAULT_USER=kyoo
      RABBITMQ_DEFAULT_PASS=xxxxxx


      # v5 stuff, does absolutely nothing on master (aka: you can delete this)
      EXTRA_CLAIMS='{"permissions": ["core.read"], "verified": false}'
      FIRST_USER_CLAIMS='{"permissions": ["users.read", "users.write", "apikeys.read", "apikeys.write", "users.delete", "core.read", "core.write"], "verified": true}'
      GUEST_CLAIMS='{"permissions": ["core.read"]}'
      PROTECTED_CLAIMS="permissions,verified"
    '';
  };

  virtualisation.oci-containers.containers = {
    "traefik" = {
      image = "traefik:latest";
      cmd = [
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"
        "--entryPoints.web.address=:8901"
        "--accesslog=true"
      ];
      ports = [
        "8901:8901"
      ];
      volumes = [
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
    };

    "kyoo-back" = {
      pull = "newer";
      image = "ghcr.io/zoriya/kyoo_back:latest";
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.api.rule" = "PathPrefix(`/api/`)";
      };
      environmentFiles = [/etc/kyoo-environmentFile];
      environment = {
        TRANSCODER_URL = "http://kyoo-transcoder:7666/video";
        KYOO_PREFIX = "/api";
      };
      dependsOn = [
        "postgres"
        "meilisearch"
        "rabbitmq"
      ];
      volumes = [
        "${METADATA-ROOT}:/metadata"
      ];
    };

    "kyoo-front" = {
      pull = "newer";
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.front.rule" = "PathPrefix(`/`)";
      };
      image = "ghcr.io/zoriya/kyoo_front:latest";
      environmentFiles = [/etc/kyoo-environmentFile];
    };

    "kyoo-migrations" = {
      pull = "newer";
      image = "ghcr.io/zoriya/kyoo_migrations:latest";
      dependsOn = ["postgres"];
      environmentFiles = [/etc/kyoo-environmentFile];
    };

    "kyoo-scanner" = {
      pull = "newer";
      image = "ghcr.io/zoriya/kyoo_scanner:latest";
      dependsOn = ["kyoo-back"];
      environmentFiles = [/etc/kyoo-environmentFile];
      volumes = [
        "${LIBRARY-ROOT}:/video:ro"
      ];
    };

    "kyoo-matcher" = {
      pull = "newer";
      image = "ghcr.io/zoriya/kyoo_scanner:latest";
      cmd = ["matcher"];
      dependsOn = ["kyoo-back"];
      environmentFiles = [/etc/kyoo-environmentFile];
    };

    "kyoo-autosync" = {
      pull = "newer";
      environmentFiles = [/etc/kyoo-environmentFile];
      image = "ghcr.io/zoriya/kyoo_autosync:latest";
    };

    "kyoo-transcoder" = {
      pull = "newer";
      image = "ghcr.io/zoriya/kyoo_transcoder:latest";
      environment = {
        GOCODER_PREFIX = "/video";
        GOCODER_HWACCEL = "cpu";
        # GOCODER_VAAPI_RENDERER = "/dev/dri/renderD128";
      };
      environmentFiles = [/etc/kyoo-environmentFile];
      volumes = [
        "${LIBRARY-ROOT}:/video:ro"
        "${CACHE-ROOT}:/cache"
        "${METADATA-ROOT}:/metadata"
      ];
    };

    "postgres" = {
      pull = "newer";
      image = "postgres:17-alpine";
      volumes = [
        "postgres:/var/lib/postgresql/data"
      ];
      environmentFiles = [/etc/kyoo-environmentFile];
    };

    "meilisearch" = {
      pull = "newer";
      image = "getmeili/meilisearch:v1.4";
      volumes = [
        "meilisearch:/meili_data"
      ];
      environment = {
        MEILI_ENV = "production";
      };
      environmentFiles = [/etc/kyoo-environmentFile];
      ports = [
        "127.0.0.1:7700:7700"
      ];
    };

    "rabbitmq" = {
      pull = "newer";
      image = "rabbitmq:4-alpine";
      environmentFiles = [/etc/kyoo-environmentFile];
    };
  };
}
