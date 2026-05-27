{pkgs, ...}: {
  # environment.etc."hermes-agent/environmentFiles" = {
  #   mode = "0644";
  #   text = ''
  #     OPENROUTER_API_KEY=
  #   '';
  # };

  # see https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
  services.hermes-agent = {
    enable = true;
    configFile = "/etc/hermes-agent/config.yaml";
    # environment = {
    #   OPENROUTER_API_KEY = "";
    # };
    # environmentFiles = [
    #   "/etc/hermes-agent/environmentFiles"
    # ];
    mcpServers = {
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };
    };
    addToSystemPackages = true;
  };

  environment.etc."hermes-agent/config.yaml" = {
    mode = "0644";
    # By using `hermes setup` command to generate config.yaml
    text = "
    ";
  };
}
