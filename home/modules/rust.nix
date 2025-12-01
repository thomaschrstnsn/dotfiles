{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.rust;

  linkerPkg = linker: if linker == "lld" then pkgs.lld else pkgs.mold;
in
{
  options.tc.rust = with types; {
    enable = mkEnableOption "rust(up)";

    linker = mkOption {
      type = enum [ "lld" "mold" ];
      default = "lld";
      description = "linker to use";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [ rustup ];

      programs.fish.interactiveShellInit = ''
        set PATH $PATH ~/.cargo/bin
      '';

      programs.zsh.initContent = ''
        export PATH=$PATH:~/.cargo/bin
      '';
    }
    (mkIf (pkgs.stdenv.isDarwin == false)
      {
        home.packages = with pkgs; [ (linkerPkg cfg.linker) clang ];
        home.file = {
          ".cargo/config.toml" = {
            source = (pkgs.formats.toml { }).generate "cargo-config.toml"
              {
                target.x86_64-unknown-linux-gnu = {
                  linker = "clang";
                  rustflags = [ "-C" "link-arg=-fuse-ld=${cfg.linker}" ];
                };
              };
          };
        };
      }
    )
  ]);
}
