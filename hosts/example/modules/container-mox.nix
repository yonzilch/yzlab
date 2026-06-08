# container-mox.nix
#
# NixOS OCI container configuration for mox mail server.
# Domain : yzlab.eu.org
# MX/rDNS: mail.yzlab.eu.org
#
# ─── First-time setup ────────────────────────────────────────────────────────
#
#   1. Create host directories (once, before first deploy):
#        mkdir -p /var/lib/mox/{config,data,web}
#
#   2. Run the quickstart inside a throw-away container to generate
#      config/mox.conf and config/domains.conf:
#
#        docker run --rm -it \
#          -e MOX_DOCKER=yes \
#          -v /var/lib/mox/config:/mox/config \
#          -v /var/lib/mox/data:/mox/data \
#          -v /var/lib/mox/web:/mox/web \
#          -w /mox \
#          r.xmox.nl/mox:latest \
#          mox quickstart you@yzlab.eu.org
#
#      Follow the printed instructions:
#        • Copy the DNS records into your registrar / DNS provider.
#        • Note the generated admin password.
#
#   3. nixos-rebuild switch  →  the mox container starts automatically.
#
#   4. Admin panel (over SSH tunnel):
#        ssh -L 8080:127.0.0.1:8080 user@your-vps
#      then open  http://localhost:8080/admin/
#      (mox binds the admin panel to all interfaces on port 80 by default;
#       adjust AdminHTTP.Port in mox.conf if you want a private port)
#
# ─── Ports used by mox (all via host network) ────────────────────────────────
#
#   25   – SMTP  (inbound from the internet)
#   587  – Submission / STARTTLS  (email clients)
#   465  – Submissions / TLS  (email clients)
#   143  – IMAP / STARTTLS  (email clients)
#   993  – IMAPS / TLS  (email clients)
#   80   – HTTP  (ACME TLS-challenge + redirect to HTTPS)
#   443  – HTTPS (ACME, webmail, admin, autoconfig, MTA-STS)
#
# ─────────────────────────────────────────────────────────────────────────────
_: {
  # Ensure host directories exist before the container service starts.
  systemd.tmpfiles.rules = [
    "d /var/lib/mox         0750 root root -"
    "d /var/lib/mox/config  0750 root root -"
    "d /var/lib/mox/data    0750 root root -"
    "d /var/lib/mox/web     0750 root root -"
  ];

  virtualisation.oci-containers.containers."mox" = {
    image = "r.xmox.nl/mox:latest";
    pull = "newer";

    environment = {
      # Tells quickstart not to attempt writing a systemd unit file.
      MOX_DOCKER = "yes";
    };

    volumes = [
      "/var/lib/mox/config:/mox/config"
      "/var/lib/mox/data:/mox/data"
      "/var/lib/mox/web:/mox/web"
    ];

    workdir = "/mox";

    # ── Host networking is REQUIRED for mox ──────────────────────────────────
    # Mox must see the real public IP of every inbound connection for:
    #   • Junk / spam scoring and reputation tracking
    #   • Per-IP rate limiting
    #   • SPF/iprev checks
    # It also needs to bind outgoing connections to the correct public IP so
    # that PTR / rDNS and SPF records match.
    # Bridge or NAT networking breaks all of the above.
    extraOptions = ["--network=host"];
  };
}
