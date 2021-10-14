# dotfiles aka home-manager as a nix flake

personal dotfiles for Thomas Christensen

## pre-requisites

- [Nix](https://nixos.org/manual/nix/stable/#chap-installation)
- Experimental [`nix flake` support](https://nixos.wiki/wiki/flakes#Installing_flakes) until released

## usage

`./apply-user.sh` will apply the configuration defined as `$HOST`.`$USER` in `flake.nix`

hint: to apply and reload: `./apply-user.sh && reload_zshrc`

to preview changes without applying:

`./build.user.sh`

