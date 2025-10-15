{ pkgs, config, lib, ... }:
with lib;

let
  # lifted from https://its.mw/posts/updating-my-keymaps-in-kitty-and-neovim/
  check-terminal-color-and-fonts = pkgs.writeShellApplication {
    name = "check-terminal-color-and-fonts";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      awk 'BEGIN{
          s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
          for (colnum = 0; colnum<77; colnum++) {
              r = 255-(colnum*255/76);
              g = (colnum*510/76);
              b = (colnum*255/76);
              if (g>255) g = 510-g;
              printf "\033[48;2;%d;%d;%dm", r,g,b;
              printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
              printf "%s\033[0m", substr(s,colnum+1,1);
          }
          printf "\n";
      }'

      echo -e '\e[4munderline\e[24m'
      echo -e '\e[4:2mdouble underline\e[24m'
      echo -e '\e[4:3mcurly underline\e[4:0m'
      echo -e '\e[4:4mdotted underline\e[4:0m'
      echo -e '\e[4:5mdashed underline\e[4:0m'
      echo -e '\e[21m\e[58:5:42m256-color underline\e[59m\e[24m'
      echo -e '\e[4:3m\e[58;2;240;143;104mtruecolor underline\e[59m\e[4:0m'

      echo -e "\e[1mbold\e[0m"
      echo -e "\e[3mitalic\e[0m"
      echo -e "\e[3m\e[1mbold italic\e[0m"
      echo -e "\e[4munderline\e[0m"
      echo -e "\e[9mstrikethrough\e[0m"
    '';
  };

  # https://kokada.capivaras.dev/blog/quick-bits-realise-nix-symlinks/
  realise-symlink = pkgs.writeShellApplication {
    name = "realise-symlink";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      for file in "$@"; do
        if [[ -L "$file" ]]; then
          if [[ -d "$file" ]]; then
            tmpdir="''${file}.tmp"
            mkdir -p "$tmpdir"
            cp --verbose --recursive "$file"/* "$tmpdir"
            unlink "$file"
            mv "$tmpdir" "$file"
            chmod --changes --recursive +w "$file"
          else
            cp --verbose --remove-destination "$(readlink "$file")" "$file"
            chmod --changes +w "$file"
          fi
        else
          >&2 echo "Not a symlink: $file"
          exit 1
        fi
      done
    '';
  };

  convert-to-flac = pkgs.writeShellApplication {
    name = "convert-to-flac";
    runtimeInputs = with pkgs; [ ffmpeg ];
    text = ''
      # Check if exactly 2 arguments are provided
      if [ $# -ne 2 ]; then
          echo "Usage: $0 <input_file> <output_file>"
          echo "Example: $0 input.wav output.flac"
          exit 1
      fi

      # Check if input file exists
      if [ ! -f "$1" ]; then
          echo "Error: Input file '$1' does not exist"
          exit 1
      fi

      ffmpeg -i "$1" -c:a flac "$2"
    '';
  };

  convert-to-mp3 = pkgs.writeShellApplication {
    name = "convert-to-mp3";
    runtimeInputs = with pkgs; [ ffmpeg ];
    text = ''
      # Check if exactly 2 arguments are provided
      if [ $# -ne 2 ]; then
          echo "Usage: $0 <input_file> <output_file>"
          echo "Example: $0 input.wav output.mp3"
          exit 1
      fi

      # Check if input file exists
      if [ ! -f "$1" ]; then
          echo "Error: Input file '$1' does not exist"
          exit 1
      fi

      ffmpeg -i "$1" -c:a libmp3lame -q:a 8 "$2"
    '';
  };

  youtube-download-audio = pkgs.writeShellApplication {
    name = "youtube-download-audio";
    runtimeInputs = with pkgs; [ ffmpeg yt-dlp ];
    text = ''
      # Check if exactly 1 arguments are provided
      if [ $# -ne 1 ]; then
          echo "Usage: $0 <url>"
          exit 1
      fi

      yt-dlp --extractor-args "youtube:player_client=android" -x --audio-format mp3 --audio-quality 0 "$1"
    '';
  };

  cfg = config.tc.scripts;
in
{
  options.tc.scripts = with types; {
    enable = (mkEnableOption "useful scripts") // { default = true; };

    onlyCore = mkEnableOption "only core (few dependencies)";
  };

  config = mkIf cfg.enable {
    home.packages =
      [
        check-terminal-color-and-fonts
        realise-symlink
      ] ++ (if cfg.onlyCore == false then [
        convert-to-flac
        convert-to-mp3
        youtube-download-audio
      ] else [ ]);
  };
}

