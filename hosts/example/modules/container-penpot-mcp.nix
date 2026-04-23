_: {
  virtualisation.oci-containers.containers."penpot-mcp" = {
    image = "sebathi/penpot-mcp-docker:latest";
    pull = "newer";
    ports = [
      "127.0.0.1:4401:4401/tcp" # MCP HTTP endpoint
      "127.0.0.1:4402:4402/tcp" # WebSocket plugin bridge
    ];
    environment = {
      "PENPOT_MCP_SERVER_LISTEN_ADDRESS" = "0.0.0.0";
      "PENPOT_MCP_SERVER_ADDRESS" = "penpot-mcp.example.com";
      "PENPOT_MCP_SERVER_PORT" = "4401";
      "PENPOT_MCP_WEBSOCKET_PORT" = "4402";
      "PENPOT_MCP_REMOTE_MODE" = "true";
    };
  };
}
