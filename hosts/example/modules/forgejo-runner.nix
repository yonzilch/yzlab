{pkgs, ...}: {
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.my-forgejo-instance = {
      enable = true;
      name = "foobar";
      token = "xxxxxx";
      url = "https://git.example.com/";
      labels = [
        # Node.js
        "node-22:docker://node:22-bookworm"
        "node-20:docker://node:20-bookworm"

        # Python
        "python-3:docker://python:3.13-bookworm"

        # Go
        "golang:docker://golang:1.24-bookworm"

        # Rust
        "rust:docker://rust:1.85-bookworm"

        # NixOS
        "nixos-latest:docker://nixos/nix"

        # Debian/Ubuntu
        "ubuntu-latest:docker://catthehacker/ubuntu:act-22.04"
        "ubuntu-22.04:docker://catthehacker/ubuntu:act-22.04"
        "ubuntu-24.04:docker://catthehacker/ubuntu:act-24.04"

        # Alpine
        "alpine:docker://alpine:latest"
      ];
      settings = {
        container = {
          network = "forgejo-actions";
          valid_volumes = []; # 禁止挂载路径
        };
      };
    };
  };

  networking.firewall.interfaces."forgejo-actions" = {
    allowedUDPPorts = [53];
  };

  systemd.services.podman-create-forgejo-network = {
    wantedBy = ["multi-user.target"];
    path = with pkgs; [zfs];
    script = ''
      ${pkgs.podman}/bin/podman network exists forgejo-actions || \
      ${pkgs.podman}/bin/podman network create \
        --ipv6 \
        --subnet 10.89.0.0/24 \
        --gateway 10.89.0.1 \
        --dns 1.1.1.1 \
        --dns 45.11.45.11 \
        --dns 9.9.9.9 \
        --dns 2606:4700:4700::1111 \
        --dns 2a09:: \
        --dns 2a0d:2a00:1::2 \
        --interface-name forgejo-actions \
        forgejo-actions
    '';
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
  };
}
