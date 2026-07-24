# yzlab

**[![README](https://img.shields.io/badge/README-white)](https://github.com/yonzilch/yzlab) | [![English](https://img.shields.io/badge/English-blue)](https://github.com/yonzilch/yzlab/blob/main/README.md) | [![中文](https://img.shields.io/badge/Chinese-red)](https://github.com/yonzilch/yzlab/blob/main/README.zh-CN.md)**

> My personal Infrastructure Lab, fully declarative and reproducible — powered by NixOS Flakes.

[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![built with nix](https://img.shields.io/badge/built%20with-Nix-7EBAE4?logo=nixos)](https://builtwithnix.org)
[![License](https://img.shields.io/github/license/yonzilch/yzlab)](./LICENSE)

---

## Live Infrastructure Overview

| Service | URL |
|---|---|
| Server monitor | [monitor.yzlab.eu.org](https://monitor.yzlab.eu.org) |
| Status page | [status.yzlab.eu.org](https://status.yzlab.eu.org) |

---

## What is this?

This code repo is a **single source of truth** for every NixOS machine in my homelab. Every host, every service, every system option is defined in code here. No manual configuration, no configuration drift — if it's not in this repo, it doesn't exist on the machine.

The stack is built around [NixOS Flakes](https://nixos.wiki/wiki/Flakes) with a focus on:

- **Reproducibility** — identical builds, every time, on any machine
- **Declarative provisioning** — fresh host to fully configured in one command
- **Secret safety** — encrypted secrets committed directly to Git
- **Operational simplicity** — complex operations wrapped into short `just` commands

Current scale: **10+ hosts**, **50+ self-hosted services**, encompassing VPS/VDS instances across multiple cloud providers, local bare-metal server hosts, and virtual machines.

---

## Why NixOS Flakes?

Most homelab setups drift over time — packages installed manually, config files tweaked in-place, undocumented one-off fixes. NixOS eliminates this entirely:

- **Atomic upgrades and rollbacks** — switch generations with a single command; roll back just as easily
- **Reproducible builds** — `flake.lock` pins every dependency; the same flake always produces the same system
- **No imperative state** — the system is a pure function of the configuration; no hidden state to worry about
- **Dev shell included** — `nix develop` drops you into a shell with all tooling (`sops`, `nixos-rebuild`, etc.) without installing anything globally

---

## Tech Stack

| Layer | Tool | Role |
|---|---|---|
| OS | [NixOS](https://nixos.org) | Declarative, atomic Linux |
| Flake framework | [flake-parts](https://github.com/hercules-ci/flake-parts) | Modular flake composition |
| Disk layout | [disko](https://github.com/nix-community/disko) | Declarative disk partitioning |
| Remote install | [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) | Zero-touch provisioning over SSH |
| Secrets | [sops-nix](https://github.com/Mic92/sops-nix) + [age](https://github.com/FiloSottile/age) | Encrypted secrets in Git |
| Task runner | [just](https://github.com/casey/just) | Ergonomic command automation |
| Formatter | [nixfmt-rs](https://github.com/Mic92/nixfmt-rs) + [deadnix](https://github.com/astro/deadnix) | Nix code quality |
| Compose bridge | [compose2nix](https://github.com/aksiksi/compose2nix) | Docker Compose → Nix translation |

---

## Repository Structure

```
yzlab/
├── flake.nix          # Flake entry point, input declarations
├── flake.lock         # Locked dependency graph
├── justfile           # Automation commands
├── .sops.yaml         # SOPS encryption rules
├── hosts/             # Per-host NixOS configurations
│   └── <hostname>/
│       ├── default.nix
│       └── hardware.nix
├── modules/           # Reusable NixOS modules
│   └── private/       # SOPS-encrypted secrets (safe to commit)
└── pkgs/              # Custom Nix packages
```

### How hosts are organized

Each host under `hosts/` is a self-contained NixOS system definition. Hardware configuration is auto-generated during provisioning via `nixos-generate-config` and committed alongside the declarative config. Shared behaviour lives in `modules/`, keeping host configs lean and focused on machine-specific concerns.

---

## Secret Management

Secrets are encrypted with [SOPS](https://github.com/getsops/sops) using an [age](https://github.com/FiloSottile/age) key and committed directly into `modules/private/`. The `.sops.yaml` defines which files are encrypted and which keys can decrypt them.

```yaml
# .sops.yaml
keys:
  - &admin_yonzilch age1yzce0p...
creation_rules:
  - path_regex: modules/private/.*
    key_groups:
      - age:
          - *admin_yonzilch
```

---

## Usage

### Prerequisites

- Nix with flakes enabled
- `just` installed
- An age key at `~/.config/sops/age/keys.txt` (generate with `just keygen`)

### Available commands

```
just keygen               # Generate a new age key via rage
just update               # Update all flake inputs
just upgrade              # Rebuild and switch the local host in-place

just build   <hostname>   # Build a host configuration (no deploy)
just build-vm <hostname>  # Build and launch as a local VM for testing

just deploy    <hostname>  # Deploy to a running remote host (nixos-rebuild switch)
just deploy-rb <hostname>  # Same, but build on the remote machine

just anywhere    <hostname>  # Provision a fresh host from scratch (nixos-anywhere)
just anywhere-lb <hostname>  # Same, build locally before sending
just anywhere-vm <hostname>  # Dry-run in a local VM

just enc  <hostname>       # Encrypt secrets for a host
just dec  <hostname>       # Decrypt secrets for a host
just eac                   # Encrypt all secrets
just dac                   # Decrypt all secrets

just format               # Format all Nix files (alejandra + deadnix)
```

### Provisioning a new host from scratch

```bash
# 1. Create host config
mkdir -p hosts/<hostname>
# ... write hosts/<hostname>/default.nix

# 2. Generate age key if you haven't already
just keygen

# 3. Provision — hardware-config is auto-generated and applied
just anywhere <hostname>
```

The `anywhere` command handles everything: updating `flake.nix` with the target hostname, auto-generating hardware configuration via `nixos-generate-config`, and deploying over SSH in a single step.

### Deploying changes to an existing host

```bash
just deploy <hostname>
```

That's it. NixOS atomically switches to the new generation; if anything goes wrong, the previous generation is intact and bootable.

---

## License

[BSD 2-Clause](./LICENSE)
