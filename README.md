# dotfiles aka home-manager nix-darwin as a nix flake

personal dotfiles for Thomas Christensen

## pre-requisites

- [Nix](https://nixos.org/manual/nix/stable/#chap-installation)
- Experimental [`nix flake` support](https://nixos.wiki/wiki/flakes#Installing_flakes) until released

## usage home-manager

`./apply-home.sh` will apply the `homeManagerConfigurations` defined as `$HOST`.`$USER` in `flake.nix`

hint: to apply and reload: `./apply-home.sh && reload_zshrc`

to preview changes without applying:

`./build-home.sh`

## usage darwin

`./apply-darwin.sh` will apply the `darwinConfigurations` defined as `$HOST` in `flake.nix`

to preview changes without applying:

`./build-darwin.sh`
