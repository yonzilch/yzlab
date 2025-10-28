# Set hostname environment
hostname := `hostname`


@anywhere input:
  # Perform nixos-anywhere install
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hosts/{{input}}/hardware.nix --flake .#{{input}} --target-host root@{{input}}


@anywhere-lb input:
  # Berform nixos-anywhere install (local builder)
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hosts/{{input}}/hardware.nix --flake .#{{input}} --target-host root@{{input}} --build-on local --show-trace


@anywhere-vm input:
  # Best nixos-anywhere install in local vm
  ls modules/private/{{input}}/* | xargs -n 1 sops decrypt -i ; sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; nix run github:nix-community/nixos-anywhere -- --flake .#{{input}} --vm-test


@build input:
  # Build
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; sudo nixos-rebuild build --flake .#{{input}} --show-trace -L -v ;


@build-vm input:
  # Build a vm
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; sudo nixos-rebuild build-vm --flake .#{{input}} --show-trace -L -v


@deploy input:
  # Perform remote deploy action
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; nixos-rebuild switch --flake .#{{input}} --target-host root@{{input}} -v


@deploy-rb input:
  # Perform remote deploy action (remote builder)
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{input}}\"/" ./flake.nix ; git add . ; nixos-rebuild switch --flake .#{{input}} --build-host root@{{input}} --target-host root@{{input}} -v


@da:
  # Decrypt all
  ls modules/private/**/* | xargs -n 1 sops decrypt -i


@de input:
  # Decrypt
  ls modules/private/{{input}}/* | xargs -n 1 sops decrypt -i


@ea:
  # encrypt all
  ls modules/private/**/* | xargs -n 1 sops encrypt -i


@en input:
  # Encrypt
  ls modules/private/{{input}}/*.nix | xargs -n 1 sops encrypt -i


@format:
  # Use alejandra and deadnix to format code
  deadnix -e ; alejandra .


@keygen:
  # Generate age key by using rage
  rage-keygen -o ~/.config/sops/age/keys.txt


@update:
  # Let flake update
  nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command --show-trace


@upgrade:
  # Let system totally upgrade
  sed -i "/^\s*hostname[[:space:]]*=[[:space:]]*\"/s/\"\(.*\)\"/\"{{hostname}}\"/" ./flake.nix ; git add . ; nixos-rebuild switch --flake .#{{hostname}} --show-trace -L -v
