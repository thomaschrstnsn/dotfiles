alias a := apply
alias f := format
alias fmt := format
alias switch := apply
alias b := build
alias c := check
alias u := update
alias brd := build-raspi-docker

_nh := if os() == "macos" { "nh darwin" } else { "nh os" }

default:
  @just --list

apply *args:
  {{_nh}} switch . {{args}}

build *args:
  {{_nh}} build . {{args}}

check *args:
  nix run github:DeterminateSystems/flake-checker {{args}}

format mode="check":
  nix run nixpkgs#nixpkgs-fmt -- {{if mode == "check" { "--check" } else { "" } }} .

clean TARGET="all":
  nh clean {{TARGET}}

update *args:
  nix flake update --commit-lock-file {{args}}

prefetch-from-github OWNER REPO *args:
  nix run nixpkgs#nix-prefetch-github -- --nix {{OWNER}} {{REPO}} {{args}}

needs-manual-update:
  rg -g "*.nix" sha256

disk-usage:
  nix run nixpkgs#nix-du -- -s=500MB | nix shell nixpkgs#graphviz --command dot -Tsvg -o disk-usage.svg

# Build one or more attributes of a nixos config inside Docker (native on Apple
# Silicon) and push their closures to the thomaschrstnsn cachix cache.
#   HOST  = nixosConfigurations.<HOST>              (default nixos-raspi-4)
#   ATTRS = space-separated attr paths under it, e.g.
#             config.system.build.toplevel       (default; the whole system)
#             config.boot.kernelPackages.kernel   (just the RPi kernel)
# Build just the kernel:  just brd nixos-raspi-4 config.boot.kernelPackages.kernel
# Requires CACHIX_AUTH_TOKEN (a cachix *write* token) in the environment.
build-raspi-docker HOST="nixos-raspi-4" ATTRS="config.system.build.toplevel":
  #!/usr/bin/env bash
  set -euo pipefail
  : "${CACHIX_AUTH_TOKEN:?set CACHIX_AUTH_TOKEN to a cachix write token for 'thomaschrstnsn'}"
  docker run --rm \
    -e CACHIX_AUTH_TOKEN \
    -v raspi-nix-store:/nix \
    -v "{{justfile_directory()}}:/workspace" \
    -w /workspace \
    nixos/nix:latest \
    sh -eu -c '
      printf "%s\n" \
        "experimental-features = nix-command flakes" \
        "extra-substituters = https://nix-community.cachix.org https://thomaschrstnsn.cachix.org" \
        "extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= thomaschrstnsn.cachix.org-1:jPfgdkADpT48y0uP/E3fPKCJuHHDe/JpRJrfyEYdxPA=" \
        >> /etc/nix/nix.conf
      printf "[safe]\n\tdirectory = *\n" > /root/.gitconfig
      set --
      for a in {{ATTRS}}; do set -- "$@" "/workspace#nixosConfigurations.{{HOST}}.$a^*"; done
      nix build "$@" --print-out-paths --no-link \
        | nix run nixpkgs#cachix -- push thomaschrstnsn
    '
