_: {
  virtualisation.oci-containers.containers."excalidraw-frontend" = {
    image = "alswl/excalidraw:v0.18.0-fork-b3";
    environment = {
      "VITE_APP_BACKEND_V2_GET_URL" = "https://excalidraw-storage.example.com/api/v2/scenes/";
      "VITE_APP_BACKEND_V2_POST_URL" = "https://excalidraw-storage.example.com/api/v2/scenes/";
      "VITE_APP_WS_SERVER_URL" = "https://excalidraw-room.example.com";
      "VITE_APP_FIREBASE_CONFIG" = "{}";
      # alswl's fork specific environment variables
      "VITE_APP_HTTP_STORAGE_BACKEND_URL" = "https://excalidraw-storage.example.com/api/v2";
      "VITE_APP_STORAGE_BACKEND" = "http";
    };
    ports = [
      "127.0.0.1:28090:80/tcp"
    ];
    dependsOn = [
      "excalidraw-storage"
      "excalidraw-room"
    ];
  };

  virtualisation.oci-containers.containers."excalidraw-storage" = {
    image = "alswl/excalidraw-storage-backend:v2023.11.11";
    environment = {
      "PORT" = "8081";
      "GLOBAL_PREFIX" = "/api/v2";
      "STORAGE_URI" = "redis://keydb:6379";
      "LOG_LEVEL" = "warn";
      "BODY_LIMIT" = "50mb";
    };
    ports = [
      "127.0.0.1:31974:8081/tcp"
    ];
    dependsOn = [
      "keydb"
    ];
  };

  virtualisation.oci-containers.containers."excalidraw-room" = {
    image = "excalidraw/excalidraw-room:sha-49bf529";
    ports = [
      "127.0.0.1:58481:80/tcp"
    ];
  };
}
