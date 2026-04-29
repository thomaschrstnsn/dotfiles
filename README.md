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

### Applying changes

`just apply` will apply the host configuration (nixos or darwin) defined as `$HOST` in `machines.nix`

To preview changes without applying: `just build`. The built configuration will be placed in `./result`.

## Updating lockfile

Use `just update` to write a new lock file (updating all the inputs)

## Listing dependents

`nix-store --query --referrers /nix/store/8mlz1pppq90x4j959932jzhm982rb2rc-gtk4-4.6.5`

## Why depends?

```bash
# home manager
nix why-depends .#homeManagerConfigurations.aeris.thomas.activationPackage nixpkgs#ghc-8.10.4
# darwin (with allow unfree)
NIXPKGS_ALLOW_UNFREE=1 nix why-depends --impure .#darwinConfigurations.aeris.system nixpkgs#nodePackages.vscode-langservers-extracted
```

## Cleaning old system generations

Running `just clean all` any older profiles.

# Inspiration

- [wiltaylor](https://github.com/wiltaylor/dotfiles) and his awesome [videos](https://www.youtube.com/watch?v=QKoQ1gKJY5A)
- [jordanisaacs](https://github.com/jordanisaacs/dotfiles)
- [hardselius](https://github.com/hardselius/dotfiles)
- [Luca Cambiaghi](https://www.lucacambiaghi.com/nixpkgs/readme.html)
- [shaunsingh](https://github.com/shaunsingh/nix-darwin-dotfiles/)
- [azuwis (aarch64)](https://github.com/azuwis/nix-config)

- Excellent introduction to nix (sans flakes it seems): [Chris Titus Tech](https://www.youtube.com/watch?v=fuWPuJZ9NcU)
