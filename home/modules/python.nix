{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.python;
  /*
    # Guide:

    ## installing a new python from the nixpkgs-python
    versions available: https://github.com/cachix/nixpkgs-python/blob/main/versions.json
    (since `pyenv nix-install --list` is not functional)

    pyenv nix-install 3.11.9

    # usage with direnv, create a .envrc with the following content

    ```
    layout pyenv 3.11.9
    ```

    this will create a new venv under `.direnv/python/` and auto-activate when entering the directory
    poetry: pip install poetry

    # uv
    is a different story, right now no support in direnv, but see
    https://offby1.website/posts/uv-direnv-and-simple-envrc-files.html

    e.g.
    ```
    uv venv
    source .venv/bin/activate
    ```
    `
  */
in
{
  options.tc.python = {
    enable = mkEnableOption "python tooling (pyenv not devenv)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      myPkgs.pyenv-nix-install
      uv
    ];
    programs.pyenv.enable = true;
  };
}
