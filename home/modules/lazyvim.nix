{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.lazyvim;

  mkIfList = cond: xs: if cond then xs else [ ];

  colorschemes = {
    lua = {
      everforest = readFile ./lazy/themes/everforest.lua;
      kanagawa = readFile ./lazy/themes/kanagawa.lua;
      rose-pine = readFile ./lazy/themes/rose-pine.lua;
      tokyonight = "";
    };
  };
in
{
  options.tc.lazyvim = with types; {
    enable = mkEnableOption "lazyvim";
    copilot.enable = mkEnableOption "copilot";
    gh.enable = mkEnableOption "gh (github cli) integation";
    lang = {
      python.enable = mkEnableOption "python";
      json.enable = mkEnableOption "json" // { default = true; };
      markdown.enable = mkEnableOption "markdown" // { default = true; };
      markdown.zk = {
        enable = mkEnableOption "Full markdown notes taking with zk";
      };
      typescript.enable = mkEnableOption "typescript";
    };
    util.rest.enable = mkEnableOption "rest client" // { default = true; };
    colorscheme = mkOption {
      type = enum [
        "everforest"
        "kanagawa"
        "rose-pine"
        "tokyonight"
      ];
      description = "colorscheme to apply";
      default = "rose-pine";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      lazyvim = {
        enable = true;
        installCoreDependencies = false;
        extras = {
          ai = {
            copilot.enable = cfg.copilot.enable;
            copilot-chat.enable = cfg.copilot.enable;
          };
          coding = {
            Blink.enable = true;
            mini-surround.enable = true;
          };
          editor = {
            inc-rename.enable = true;
            refactoring.enable = true;
            Snacks_picker.enable = true;
          };
          lang = {
            docker.enable = true;
            json.enable = cfg.lang.json.enable;
            nix.enable = true;
            markdown.enable = cfg.lang.markdown.enable;
            python.enable = cfg.lang.python.enable;
            rust.enable = true;
            toml.enable = true;
            typescript.enable = cfg.lang.typescript.enable;
          };
          lsp = { none-ls.enable = true; };
          ui = { Treesitter-context.enable = true; };
          util = { rest.enable = cfg.util.rest.enable; };
        };
        # TODO:
        # - csharp/dotnet? https://www.reddit.com/r/dotnet/comments/1keiv1m/comment/mqp6yag/
        # - dap
        # - neotest
        configFiles = ./lazy/lua;
        plugins = {
          colorscheme = colorschemes.lua."${cfg.colorscheme}";
        };

        extraPackages = with pkgs; concatLists [
          [
            lua-language-server
            nil
            nixpkgs-fmt
            shfmt
            shellcheck
            statix
            stylua
            taplo
          ]
          (mkIfList cfg.lang.markdown.enable [
            marksman
            markdownlint-cli2
          ])
          (mkIfList cfg.lang.markdown.zk.enable [ imagemagick ])
          (mkIfList (cfg.lang.markdown.zk.enable && pkgs.stdenv.isLinux) [ mermaid-cli ]) # aarch64-darwin needs wrapper for unpackaged chrome, see ../../darwin/mermaid-cli.nix
          (mkIfList (cfg.lang.markdown.zk.enable && pkgs.stdenv.isDarwin) [ pngpaste ])
          (mkIfList cfg.lang.json.enable [ vscode-langservers-extracted ])
          (mkIfList cfg.lang.typescript.enable [ typescript-language-server ])
        ];

      };
    };

    xdg.configFile = {
      "nvim/ftplugin/jjdescription.lua".source = ./lazy/ftplugin/jjdescription.lua;
    };

    home = {
      packages = with pkgs; concatLists [
        [
          figlet
          lazygit
          lolcat
          ripgrep
          fzf
        ]
        (mkIfList cfg.gh.enable [
          gh
        ])
      ];

      shellAliases = {
        vim = "nvim";
        pv = ''nvim -c 'enew' -c 'setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile' -c 'call setline(1, split(getreg("+"), "\n"))' '';
      };
    };
  };
}

