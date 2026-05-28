_: {
  virtualisation.oci-containers.containers."plantuml-server" = {
    image = "plantuml/plantuml-server:jetty";
    environment = {
      # Base URL / subpath. The value becomes the URL subpath name.
      # If not set, Jetty deploys at root path /
      # Set to "ROOT" to deploy at /ROOT, set to "plantuml" to deploy at /plantuml
      # "BASE_URL" = "ROOT";
      # Security profile (SANDBOX / INTERNET / LEGACY / UNSECURE)

      "PLANTUML_SECURITY_PROFILE" = "INTERNET";
      # Maximum width and height of generated images (pixels)
      "PLANTUML_LIMIT_SIZE" = "4096";
      # Whether to enable statistics report
      "PLANTUML_STATS" = "off";
      # JVM memory parameters
      "JAVA_OPTS" = "-Xmx512m -Xms128m";
      # Jetty thread pool (can be adjusted according to load)
      "JETTY_MAX_THREADS" = "50";
      "JETTY_MIN_THREADS" = "4";
    };
    ports = [
      "127.0.0.1:28095:8080/tcp"
    ];
    extraOptions = [
      "--no-healthcheck" # Remove container healthcheck
    ];
  };
}
