_: {
  virtualisation.oci-containers.containers."stalwart" = {
    image = "stalwartlabs/stalwart:latest";

    ports = [
      # ── Management Panel ───────────────────────────────────────────
      "127.0.0.1:24731:8080"

      # ── SMTP ───────────────────────────────────────────────
      "25:25" # SMTP
      "587:587" # SMTP Submission（STARTTLS）
      "465:465" # SMTPS（TLS）

      # ── IMAP ───────────────────────────────────────────────
      "143:143" # IMAP（STARTTLS）
      "993:993" # IMAPS（TLS）

      # ── ManageSieve ────────────────────────────────────────
      "4190:4190"

      # ── POP3 ──────────────────────────
      "110:110" # POP3
      "995:995" # POP3S（TLS）
    ];

    volumes = [
      "stalwart:/opt/stalwart"
      # Avoid creating anoymous volumes. see https://github.com/stalwartlabs/stalwart/blob/main/Dockerfile
      "stalwart_etc:/etc/stalwart"
      "stalwart_var_lib:/var/lib/stalwart"
    ];
  };
}
