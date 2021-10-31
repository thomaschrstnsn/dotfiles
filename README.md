# dotfiles aka home-manager nix-darwin as a nix flake

personal dotfiles for Thomas Christensen

## pre-requisites

- [Nix](https://nixos.org/manual/nix/stable/#chap-installation)
- Experimental [`nix flake` support](https://nixos.wiki/wiki/flakes#Installing_flakes) until released

## using home-manager

`./apply-home.sh` will apply the `homeManagerConfigurations` defined as `$HOST`.`$USER` in `flake.nix`

hint: to apply and reload: `./apply-home.sh && reload_zshrc`

to preview changes without applying:

`./build-home.sh`

## using nix-darwin

### initial bootstrap

Before doing this:
- ensure cleanup after any previous nix-darwin setup
- backup `/etc/{zsh,bash}rc` - nix-darwin will append nix stuff there
```
$ sudo cp /etc/bashrc /etc/bashrc.backup-before-darwin
$ sudo cp /etc/zshrc /etc/zshrc.backup-before-darwin
```

Bootstrap using: `./apply-darwin.sh bootstrap`

If this fails, you may need to:
- `rm ~/.nix-defexpr/channels`
- `sudo rm /etc/nix/nix.conf` (between `./build-darwin.sh bootstrap` and `./result/sw/bin/darwin-rebuild switch --flake .#bootstrap`)

when successful, open a new terminal session and continue below

### updating/refreshing

`./apply-darwin.sh` will apply the `darwinConfigurations` defined as `$HOST` in `flake.nix`

to preview changes without applying:

`./build-darwin.sh`


# Inspiration

- [wiltaylor](https://github.com/wiltaylor/dotfiles) and his awesome [videos](https://www.youtube.com/watch?v=QKoQ1gKJY5A)
- [jordanisaacs](https://github.com/jordanisaacs/dotfiles)
- [hardselius](https://github.com/hardselius/dotfiles)