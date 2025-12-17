_: {
  services.resolved = {
    enable = true;
    dnsovertls = "true";
    domains = ["~."];
    fallbackDns = [
      # CloudFlare servers
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
      "2606:4700:4700::1111#cloudflare-dns.com"
      "2606:4700:4700::1001#cloudflare-dns.com"

      # dns.sb servers
      "185.222.222.222#dot.sb"
      "45.11.45.11#dot.sb"
      "2a09::#dot.sb"
      "2a11::#dot.sb"

      # Quad9 servers
      "9.9.9.10#dns.quad9.net"
      "149.112.112.10#dns.quad9.net"
      "2620:fe::10#dns.quad9.net"
      "2620:fe::fe:10#dns.quad9.net"
    ];
  };
}
