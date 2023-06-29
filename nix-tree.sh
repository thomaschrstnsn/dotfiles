#! /usr/bin/env bash
set -e

script=$(basename "$0")
case "$script" in
    "build.sh")
        mode="build"
    ;; 
    "apply.sh")
        mode="apply"
    ;; 
    "nix-tree.sh")
        mode="nixtree"
    ;; 
    *)
        echo "invoke as either build.sh, nix-tree.sh or apply.sh - was invoked as '$script'"
        exit 1
    ;;
esac

target=$1
case "$target" in
    "home") 
        printf "%sing using home-manager\n" $mode
        DEFAULT_CONFIGURATION="$(hostname -s).${USER//\./_}" # replace . -> _
    ;;
    "darwin") 
        printf "%sing using nix-darwin\n" $mode
        DEFAULT_CONFIGURATION="$(hostname -s)"
    ;;
    "nixos") 
        printf "%sing using nixos\n" $mode
        DEFAULT_CONFIGURATION="$(hostname -s)"
    ;;
    *) 
        printf "usage:\n\t%s [target] [optional configuration] [extra params]\n" "$script"
        echo "where [target] one of:"
        printf "\thome, darwin, nixos\n"
        exit 1
    ;;
esac

shift # eat the first arg


if [[ $1 == "--"* ]] || [[ $# -eq 0 ]];
then
    CONFIGURATION=$DEFAULT_CONFIGURATION
else
    CONFIGURATION="${1:-$DEFAULT_CONFIGURATION}"
    shift
fi

echo using configuration "$CONFIGURATION" 

case "$target" in
    "home") 
        flakeuri=".#homeManagerConfigurations.$CONFIGURATION.activationPackage"
    ;;
    "darwin") 
        flakeuri=".#darwinConfigurations.$CONFIGURATION.system"
    ;;
    "nixos") 
        flakeuri=".#nixosConfigurations.$CONFIGURATION.config.system.build.toplevel"
    ;;
esac

if [[ $mode == "nixtree" ]];
then
	set -x
	nix-shell -p nix-tree --run "nix-tree --derivation $flakeuri"
	set +x
else
	set -x
	nix build "$flakeuri" "$@"
	set +x
fi

if [[ $mode != "apply" ]];
then
    exit 0
fi


case "$target" in
    "home") 
        set -x
        ./result/activate "$@"
    ;;
    "darwin") 
        set -x
        ./result/sw/bin/darwin-rebuild switch --flake .\#"$CONFIGURATION" "$@"
    ;;
    "nixos") 
        set -x
        nixos-rebuild switch --use-remote-sudo --flake .\#"$CONFIGURATION" "$@"
    ;;
esac
