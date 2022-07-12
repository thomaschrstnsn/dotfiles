# dotfiles aka machine configuration (home-manager + nix-darwin + nixos as a nix flake)

personal dotfiles for Thomas Christensen

## pre-requisites

- [Nix](https://nixos.org/manual/nix/stable/#chap-installation)
- Experimental [`nix flake` support](https://nixos.wiki/wiki/flakes#Installing_flakes) until released

## using home-manager

`./apply-home.sh` will apply the `homeManagerConfigurations` defined as `$HOST`.`$USER` in `machines.nix`

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

Bootstrap using: 
- for x64: `./apply-darwin.sh darwin-bootstrap-x64`
- for m1:  `./apply-darwin.sh darwin-bootstrap-aarch64`

If this fails, you may need to:
- `rm ~/.nix-defexpr/channels`
- `sudo rm /etc/nix/nix.conf` (between `./build-darwin.sh bootstrap` and `./result/sw/bin/darwin-rebuild switch --flake .#bootstrap`)

when successful, open a new terminal session and continue below

### updating/refreshing

`./apply-darwin.sh` will apply the `darwinConfigurations` defined as `$HOST` in `machines.nix`

to preview changes without applying:

`./build-darwin.sh`

## using nixos

`./apply-nixos.sh` will apply the nixos configuration defined for `$HOST` in `machines.nix`

to preview changes without applying: `./build-nixos.sh`

## updating lockfile

use `./update.sh` to write a new lock file (updating all the inputs)

to preview what has changed, try `./lock-to-github.sh` which can show github links to the different inputs including differences to the currently locked.

## listing dependenents

`nix-store --query --referrers /nix/store/8mlz1pppq90x4j959932jzhm982rb2rc-gtk4-4.6.5`

# Inspiration

- [wiltaylor](https://github.com/wiltaylor/dotfiles) and his awesome [videos](https://www.youtube.com/watch?v=QKoQ1gKJY5A)
- [jordanisaacs](https://github.com/jordanisaacs/dotfiles)
- [hardselius](https://github.com/hardselius/dotfiles)
- [Luca Cambiaghi](https://www.lucacambiaghi.com/nixpkgs/readme.html)
- [shaunsingh](https://github.com/shaunsingh/nix-darwin-dotfiles/)
- [azuwis (aarch64)](https://github.com/azuwis/nix-config)