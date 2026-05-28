_: {
  virtualisation.oci-containers.containers."drawio" = {
    image = "jgraph/drawio:latest";
    environment = {
      # ── Deployment URL ────────────────────────────────────────────────────
      # Full public URL of this instance, must end with "/"
      # Required for correct asset linking and sharing URLs
      "DRAWIO_SERVER_URL" = "https://drawio.example.com/";

      # Legacy base URL without trailing slash; auto-derived from
      # DRAWIO_SERVER_URL when not set — leave unset unless needed
      # "DRAWIO_BASE_URL" = "https://drawio.example.com";

      # Override the viewer JS bundle URL (leave unset to use bundled)
      # "DRAWIO_VIEWER_URL" = "";

      # Override the lightbox URL (leave unset to use default)
      # "DRAWIO_LIGHTBOX_URL" = "";

      # ── TLS / Certificates ────────────────────────────────────────────────
      # TLS is terminated by a reverse proxy (e.g. Nginx/Caddy);
      # the container runs plain HTTP internally.
      # Let's Encrypt and self-signed cert generation are disabled.
      "LETS_ENCRYPT_ENABLED" = "false";
      "DRAWIO_USE_HTTP" = "true"; # plain HTTP inside container

      # Certificate fields below are unused (no TLS in container),
      # listed here for completeness.
      # "PUBLIC_DNS"       = "draw.example.com";
      # "ORGANISATION_UNIT"= "Cloud Native Application";
      # "ORGANISATION"     = "example inc";
      # "CITY"             = "Paris";
      # "STATE"            = "Paris";
      # "COUNTRY_CODE"     = "FR";
      # "KEYSTORE_PASS"    = "";
      # "KEY_PASS"         = "";

      # ── Editor & Security ─────────────────────────────────────────────────
      # JSON blob injected as window.DRAWIO_CONFIG in the editor.
      # See https://www.drawio.com/doc/faq/configure-diagram-editor
      # "DRAWIO_CONFIG" = ''{"defaultFonts":[]}'';

      # Custom Content-Security-Policy header value.
      # Leave unset to use the built-in default policy.
      # "DRAWIO_CSP_HEADER" = "";

      # Enable /proxy endpoint to load external images.
      # Only enable if users need to embed remote images.
      # "ENABLE_DRAWIO_PROXY" = "1";

      # ── Export Service ────────────────────────────────────────────────────
      # Set to "1" to route export requests through the internal proxy,
      # useful when the export server is not publicly reachable.
      # "DRAWIO_SELF_CONTAINED" = "1";

      # Custom export server URL (leave unset to use the default)
      # "EXPORT_URL" = "";

      # ── Cloud Storage (all disabled) ──────────────────────────────────────
      # Google Drive
      # "DRAWIO_GOOGLE_CLIENT_ID"              = "";
      # "DRAWIO_GOOGLE_CLIENT_SECRET"          = "";
      # "DRAWIO_GOOGLE_APP_ID"                 = "";
      # "DRAWIO_GOOGLE_VIEWER_CLIENT_ID"       = "";
      # "DRAWIO_GOOGLE_VIEWER_CLIENT_SECRET"   = "";
      # "DRAWIO_GOOGLE_VIEWER_APP_ID"          = "";

      # Microsoft OneDrive / MS Graph
      # "DRAWIO_MSGRAPH_CLIENT_ID"    = "";
      # "DRAWIO_MSGRAPH_CLIENT_SECRET"= "";
      # "DRAWIO_MSGRAPH_TENANT_ID"    = "";

      # GitLab
      # "DRAWIO_GITLAB_ID"     = "";
      # "DRAWIO_GITLAB_SECRET" = "";
      # "DRAWIO_GITLAB_URL"    = "";
    };

    ports = [
      "127.0.0.1:28099:8080/tcp"
    ];

    extraOptions = [
      "--no-healthcheck"
    ];
  };
}
