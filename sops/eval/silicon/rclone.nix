{pkgs, ...}: {
  # Install rclone package
  environment.systemPackages = with pkgs; [
    fuse
    rclone
  ];
  environment.etc."rclone.conf" = {
    mode = "0755";
    text = ''
      [ia]
      type = internetarchive

      [download]
      type = union
      upstreams = ia:W0FuaW1lLTFd ia:W0FuaW1lLTJd ia:W0FuaW1lLTNd ia:W0FuaW1lLTRd ia:W0FuaW1lLTVd ia:W01vdmllLTFd ia:W01vdmllLTJd

      [yzlab]
      type = internetarchive
      access_key_id = 06Jz4kZdPWn9pnK1
      secret_access_key = PkCIOILTPSxBobmE

      [walpole177]
      type = internetarchive
      access_key_id = xxZ6YHXwsTrwaFqu
      secret_access_key = 39ivdqoReimUx0NP
    '';
  };

  programs.fuse.userAllowOther = true;

  # Create the mount directory
  systemd.tmpfiles.rules = [
    "d /download 0755 root root - -"
  ];

  # Configure the rclone mount
  systemd.services."mount-download" = {
    description = "Mount rclone download remote";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone mount download: /download --config=/etc/rclone.conf --cache-dir=/var/rclone --dir-cache-time=7500h --rc --rc-addr=127.0.0.1:1234 --rc-no-auth --read-only --allow-other --vfs-cache-mode=writes";
      Restart = "on-failure";
      RestartSec = "10s";
      User = "root";
      Group = "root";

      AmbientCapabilities = ["CAP_SYS_ADMIN"];
      CapabilityBoundingSet = ["CAP_SYS_ADMIN"];
      Environment = [
        "PATH=/run/current-system/sw/bin"
      ];
      TimeoutStartSec = "60s";
      TimeoutStopSec = "60s";
      KillMode = "mixed";
      KillSignal = "SIGINT";
    };
  };
}
