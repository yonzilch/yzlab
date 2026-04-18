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
    };
  };
}
