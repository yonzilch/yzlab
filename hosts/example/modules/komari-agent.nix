_: {
  services.komari-agent = {
    enable = true;
    flags = "";
  };
}
# Flags:
#       --auto-discovery string            Auto discovery key for the agent
#       --cf-access-client-id string       Cloudflare Access Client ID
#       --cf-access-client-secret string   Cloudflare Access Client Secret
#       --custom-dns string                Custom DNS server to use (e.g. 8.8.8.8, 114.114.114.114). By default, the program uses the system DNS resolver.
#       --disable-auto-update              Disable automatic updates
#       --disable-web-ssh                  Disable remote control(web ssh and rce)
#   -e, --endpoint string                  API endpoint
#       --exclude-nics string              Comma-separated list of network interfaces to exclude
#       --gpu                              Enable detailed GPU monitoring (usage, memory, multi-GPU support)
#   -h, --help                             help for komari-agent
#   -u, --ignore-unsafe-cert               Ignore unsafe certificate errors
#       --include-mountpoint string        Semicolon-separated list of mount points to include for disk statistics
#       --include-nics string              Comma-separated list of network interfaces to include
#       --info-report-interval int         Interval in minutes for reporting basic info (default 5)
#   -i, --interval float                   Interval in seconds (default 1)
#   -r, --max-retries int                  Maximum number of retries (default 3)
#       --memory-include-cache             Include cache/buffer in memory usage
#       --month-rotate int                 Month reset for network statistics (0 to disable)
#   -c, --reconnect-interval int           Reconnect interval in seconds (default 5)
#   -t, --token string                     API token

