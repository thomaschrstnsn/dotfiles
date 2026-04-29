# Agent Guidelines for NixOS/Darwin Dotfiles

## Version Control

- **Primary VCS**: This project uses Jujutsu (jj) as the primary version control system
- **Git Integration**: Git is used for remote operations, so "detached HEAD" states are normal and not problematic
- **Workflow**: Use `jj` commands for local development, git state is managed automatically

## Build/Test Commands

- **Build**: `just build` - Build configuration without applying
- **Apply**: `just apply` - Build and apply configuration
- **Lint**: `just check` - Check flake syntax and structure

## Code Style Guidelines

- **Nix**: Use `with lib;` imports, `mkOption`/`mkEnableOption` for options, `mkIf` for conditionals
- **Formatting**: All Nix code must be formatted with `nixpkgs-fmt` before committing.
  Format can be checked by `just format check` and `just format update` will make any needed changes.
- **Indentation**: 2 spaces for Nix, 4 spaces for Lua, tabs for shell scripts
- **Naming**: kebab-case for files, camelCase for Nix attributes, snake_case for shell variables
- **Imports**: Group by type - stdlib, nixpkgs, local modules
- **Options**: Define in `options.tc.*` namespace with proper types and descriptions
- **Config**: Use `config = mkIf cfg.enable { ... }` pattern for conditional configs
- **Lua**: Use double quotes, local variables, proper error handling with pcall
- **Shell**: Use `set -e`, quote variables, prefer `[[ ]]` over `[ ]`

## File Organization

- `home/modules/` - Home Manager configurations
- `darwin/modules/` - macOS-specific configurations  
- `nixos/modules/` - NixOS system configurations
- `machines/` - Per-machine configurations
- `pkgs/` - Custom package definitions
