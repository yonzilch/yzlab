_: {
  virtualisation.oci-containers.containers."hermes-agent" = {
    image = "nousresearch/hermes-agent:latest";
    pull = "newer";
    environment = {
      # see https://hermes-agent.nousresearch.com/docs/reference/environment-variables
    };
    volumes = [
      "hermes_agent_data:/data:rw"
    ];
  };
}
