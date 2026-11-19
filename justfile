alias a := apply
alias f := format
alias fmt := format
alias switch := apply
alias b := build
alias c := check
alias u := update

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

# List the flake's direct inputs (the names `update` accepts)
inputs:
  @nix flake metadata --json | jq -r '.locks.nodes[.locks.root].inputs | keys[]'

# Pick inputs to update with fzf (tab to multi-select)
update-select:
  #!/usr/bin/env bash
  set -euo pipefail
  selected=$(just inputs | fzf -m --prompt="update> ") || exit 0
  [[ -n "$selected" ]] || exit 0
  just update $selected

prefetch-from-github OWNER REPO *args:
  nix run nixpkgs#nix-prefetch-github -- --nix {{OWNER}} {{REPO}} {{args}}

needs-manual-update:
  rg -g "*.nix" sha256

disk-usage:
  nix run nixpkgs#nix-du -- -s=500MB | nix shell nixpkgs#graphviz --command dot -Tsvg -o disk-usage.svg

_builder_ssh_config := env("HOME") / ".cache/raspi-builder/ssh_config"

# Reachable over ssh as `raspi-builder` (127.0.0.1:2222), with its store on the
# raspi-nix-store docker volume. Your ssh-agent keys are authorized for root.
# Start (if needed) a persistent aarch64-linux Nix builder container
raspi-builder-up:
  #!/usr/bin/env bash
  set -euo pipefail
  mkdir -p "$(dirname "{{_builder_ssh_config}}")"
  printf '%s\n' \
    "Host raspi-builder" \
    "  HostName 127.0.0.1" \
    "  Port 2222" \
    "  User root" \
    "  StrictHostKeyChecking no" \
    "  UserKnownHostsFile /dev/null" \
    "  LogLevel ERROR" \
    "  ServerAliveInterval 15" \
    "Match all" \
    "Include ~/.ssh/config" \
    > "{{_builder_ssh_config}}"
  if [[ "$(docker inspect -f '{{{{.State.Running}}' raspi-builder 2>/dev/null)" != "true" ]]; then
    docker rm -f raspi-builder >/dev/null 2>&1 || true
    keys="$(ssh-add -L)" || { echo "no keys in ssh-agent" >&2; exit 1; }
    docker run -d --name raspi-builder \
      -e AUTHORIZED_KEYS="$keys" \
      -p 127.0.0.1:2222:22 \
      -v raspi-nix-store:/nix \
      -v "{{justfile_directory()}}/machines/nixos-raspi-4/docker-builder.sh:/entrypoint.sh:ro" \
      nixos/nix:latest \
      sh /entrypoint.sh >/dev/null
  fi
  for _ in $(seq 1 120); do
    ssh -F "{{_builder_ssh_config}}" -o ConnectTimeout=2 raspi-builder true 2>/dev/null && exit 0
    sleep 2
  done
  echo "raspi-builder did not come up; see: docker logs raspi-builder" >&2
  exit 1

# Stop and remove the builder container (the Nix store volume is kept)
raspi-builder-down:
  docker rm -f raspi-builder

#   ACTION = switch | boot | test | build
# e.g. just deploy-raspi            (switch nixos-raspi-4 on rpi4)
#      just deploy-raspi boot nixos-raspi-4 rpi4 --show-trace
# NH_NO_SYSTEMD_RUN: nh 4.5 wraps activation in `systemd-run --wait --verbose`,
# which on the Pi fails with "Failed to start transient service unit: Transport
# endpoint is not connected"; run switch-to-configuration directly instead.
# Build HOST in the docker builder and deploy it to TARGET over ssh with nh
deploy-raspi ACTION="switch" HOST="nixos-raspi-4" TARGET="rpi4" *args: raspi-builder-up
  NH_NO_SYSTEMD_RUN=1 NH_SSHOPTS="-F {{_builder_ssh_config}}" nh os {{ACTION}} . -H {{HOST}} --build-host raspi-builder --target-host {{TARGET}} {{args}}
