{
  lib,
  pkgs,
  ...
}: let
  # Using the same key as the main system SSH host key ensures
  # SSH clients won't see a fingerprint change between initrd
  # unlock and normal boot.
  #
  # Must NOT have a passphrase.
  # Generate with:
  #   ssh-keygen -t ed25519 -N "" -C "ssh@<hostname>"
  sshHostKey = {
    private = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      xxxxxx
      -----END OPENSSH PRIVATE KEY-----
    '';

    public = ''
      ssh-ed25519 xxxxxx ssh@<hostname>
    '';
  };

  # Authorized SSH keys for initrd remote unlock
  # Generate with: ssh-keygen -t ed25519 -a 256 -C "root@<hostname>"
  # Can be the same key as users.users.root.openssh.authorizedKeys.keys
  authorizedKeys = [
    "ssh-ed25519 xxxxxx root@<hostname>"
  ];
in {
  # =============================================
  # Remote LUKS Unlock via SSH in initrd (Early Boot)
  # =============================================
  #
  # Usage:
  #   1. Boot the system
  #   2. Connect: ssh -p 222 root@<host-ip>
  #   3. Run: systemd-tty-ask-password-agent
  #   4. Enter your LUKS passphrase when prompted

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "virtio_net"
        "virtio_pci"
      ];

      kernelModules = [
        "virtio_net"
        "virtio_pci"
      ];

      network = {
        # See https://mynixos.com/nixpkgs/option/boot.initrd.network.enable
        enable = true;

        ssh = {
          enable = true;
          port = 222; # Same port as services.openssh.ports (recommended)
          authorizedKeys = authorizedKeys;

          # Use the same host key as the main system to avoid fingerprint warnings
          hostKeys = ["/etc/secrets/initrd/ssh_hostKey"];
        };
      };

      # Secrets that are copied into the initrd
      secrets = lib.mkForce {
        # Must be passphrase-less. Recommended to use the same key as the main system.
        "/etc/secrets/initrd/ssh_hostKey" = pkgs.writeText "ssh_hostKey" sshHostKey.private;
      };

      # Network (choose one kind between boot.initrd.systemd.network and boot.initrd.kernelParams)
      systemd.network = {
        enable = true;
        networks."10-eth0" = {
          matchConfig.Name = "eth0";
          address = [
            "192.168.1.100/24"
            "2606:4700:4700::1001/64"
          ];
          gateway = ["192.168.1.1"];
          routes = [
            {
              Destination = "::/0";
              Gateway = "2606:4700:4700::1111";
            }
          ];
        };
      };
    };

    # Static IP configuration for networking
    # Format: ip=<client-ip>::<gateway>:<netmask>::<interface>:<autoconf>
    # kernelParams = [
    #   "ip=192.168.1.100::192.168.1.1:255.255.255.0::eth0:none"
    # ];
  };

  # =============================================
  # Main system SSH host key (shared with initrd)
  # =============================================
  environment.etc = {
    "ssh/ssh_hostKey" = {
      mode = "0600";
      text = sshHostKey.private;
    };

    "ssh/ssh_hostKey.pub" = {
      mode = "0644";
      text = sshHostKey.public;
    };
  };

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_hostKey";
      type = "ed25519";
    }
  ];
}
