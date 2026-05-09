_: {
  services.nextjs-ollama-llm-ui = {
    enable = true;
    hostname = "0.0.0.0";
    ollamaUrl = "http://127.0.0.1:11434";
    port = 3000;
  };
  networking.firewall = {
    allowedTCPPorts = [3000];
  };
}
