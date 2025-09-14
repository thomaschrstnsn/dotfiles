{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.rust;
in
{
  options.tc.rust = with types; {
    enable = mkEnableOption "rust(up)";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      rustup
    ];
    programs.fish.interactiveShellInit = ''
      set PATH $PATH ~/.cargo/bin
    '';

    programs.zsh.initContent = ''
      export PATH=$PATH:~/.cargo/bin
    '';
  };
}
