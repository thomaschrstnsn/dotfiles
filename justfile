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

prefetch-from-github OWNER REPO *args:
  nix run nixpkgs#nix-prefetch-github -- --nix {{OWNER}} {{REPO}} {{args}}

needs-manual-update:
  rg -g "*.nix" sha256

disk-usage:
  nix run nixpkgs#nix-du -- -s=500MB | nix shell nixpkgs#graphviz --command dot -Tsvg -o disk-usage.svg
