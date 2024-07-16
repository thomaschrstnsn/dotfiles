# dotfiles aka machine configuration 

This is the personal configuration for Thomas Christensen.

Feel free to borrow parts and/or make your own based on this.

A configuration setup based on Nix flakes for: 

- [Home Manager](https://github.com/nix-community/home-manager)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [NixOS](https://nixos.org/)

As such it can be used to configure: 
- my home directory (shell and utils, dev setup) on a UNIX system (using Nix the package manager with Home Manager)
- my macOS user (defaults, apps and the above) (using Nix the package manager with nix-darwin)
- a full machine running NixOS (apps, services, hardware and kernel config)

A motivation/overview of Nix flakes for configuring machines: 
[NIX FLAKES, PART 3: MANAGING NIXOS SYSTEMS](https://www.tweag.io/blog/2020-07-31-nixos-flakes/).

## Prerequisites

- [Nix](https://nixos.org/manual/nix/stable/#chap-installation)
- Experimental [`nix flake` support](https://nixos.wiki/wiki/flakes#Installing_flakes) until released

## Using home-manager

`./apply.sh home` will apply the `homeManagerConfigurations` defined as `$HOST`.`$USER` in `machines.nix`

hint: to apply and reload: `./apply.sh home && reload_zshrc`

to preview changes without applying:

`./build.sh home`

## Using nix-darwin

The nix-darwin (Nix on macOS) can be configured to use [Yabai](https://github.com/koekeishiya/yabai) + [SKHD](https://github.com/koekeishiya/skhd) 
(tiling window manager with a hotkey daemon). For more information on this type of setup, 
see this [video](https://www.youtube.com/watch?v=k94qImbFKWE).

### Install Nix

Use [The Determinate Nix Installer](https://zero-to-nix.com/concepts/nix-installer) to install nix with flakes on your macOS machine.

### Applying changes

`./apply.sh darwin` will apply the `darwinConfigurations` defined as `$HOST` in `machines.nix`

To preview changes without applying: `./build.sh darwin`. The built configuration will be placed in `./result`.

## Using nixos

`./apply.sh nixos` will apply the nixos configuration defined for `$HOST` in `machines.nix`.

To preview changes without applying: `./build.sh nixos`

## Updating lockfile

Use `./update.sh` to write a new lock file (updating all the inputs)

To preview what has changed, try `./lock-to-github.sh` which can show github links to the different inputs including differences to the currently locked.

## Listing dependents

`nix-store --query --referrers /nix/store/8mlz1pppq90x4j959932jzhm982rb2rc-gtk4-4.6.5`

## `nix-tree.sh`

As with `apply.sh` and `build.sh`, this command will invoke [`nix-tree`](https://github.com/utdemir/nix-tree) with the current (or specified) configuration.

## Why depends?

```bash
# home manager
nix why-depends .#homeManagerConfigurations.aeris.thomas.activationPackage nixpkgs#ghc-8.10.4
# darwin (with allow unfree)
NIXPKGS_ALLOW_UNFREE=1 nix why-depends --impure .#darwinConfigurations.aeris.system nixpkgs#nodePackages.vscode-langservers-extracted
```

## Cleaning old system generations

Running `./clean-old-generations.sh` (as with `sudo` for nixos/nix-darwin) will clean any profiles older than 30 days.

# Inspiration

- [wiltaylor](https://github.com/wiltaylor/dotfiles) and his awesome [videos](https://www.youtube.com/watch?v=QKoQ1gKJY5A)
- [jordanisaacs](https://github.com/jordanisaacs/dotfiles)
- [hardselius](https://github.com/hardselius/dotfiles)
- [Luca Cambiaghi](https://www.lucacambiaghi.com/nixpkgs/readme.html)
- [shaunsingh](https://github.com/shaunsingh/nix-darwin-dotfiles/)
- [azuwis (aarch64)](https://github.com/azuwis/nix-config)

- Excellent introduction to nix (sans flakes it seems): [Chris Titus Tech](https://www.youtube.com/watch?v=fuWPuJZ9NcU)
