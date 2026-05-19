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
      tokyonight = readFile ./lazy/themes/tokyonight.lua;
    };
  };
in
{
  options.tc.lazyvim = with types; {
    enable = mkEnableOption "lazyvim";
    copilot.enable = mkEnableOption "copilot";
    gh.enable = mkEnableOption "gh (github cli) integation";
    _99.enable = mkEnableOption "primeagen/99 tradcoding plugin";
    lang = {
      docker.enable = mkEnableOption "docker" // { default = true; };
      json.enable = mkEnableOption "json" // { default = true; };
      markdown.enable = mkEnableOption "markdown" // { default = true; };
      markdown.zk = {
        enable = mkEnableOption "Full markdown notes taking with zk";
      };
      python.enable = mkEnableOption "python";
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
        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers;
          [
            graphql
            http
          ];
        extras = {
          ai = {
            copilot.enable = cfg.copilot.enable;
            copilot-chat.enable = cfg.copilot.enable;
          };
          coding = {
            blink.enable = true;
            mini-surround.enable = true;
          };
          dap = { core.enable = true; };
          editor = {
            inc-rename.enable = true;
            refactoring.enable = true;
            snacks-picker.enable = true;
          };
          formatting = {
            prettier.enable = cfg.lang.typescript.enable;
          };
          linting = {
            eslint.enable = cfg.lang.typescript.enable;
          };
          lang = {
            docker = {
              enable = cfg.lang.docker.enable;
              installDependencies = true;
            };
            json = {
              enable = cfg.lang.json.enable;
              installDependencies = true;
            };
            nix.enable = true;
            markdown = {
              enable = cfg.lang.markdown.enable;
              installDependencies = true;
            };
            python = {
              enable = cfg.lang.python.enable;
              installDependencies = true;
            };
            rust.enable = true;
            toml = {
              enable = true;
              installDependencies = true;
            };
            typescript = {
              enable = cfg.lang.typescript.enable;
              vtsls = {
                enable = cfg.lang.typescript.enable;
                installDependencies = true;
              };
              installDependencies = true;
            };
            yaml.enable = true;
          };
          lsp = { none-ls.enable = true; };
          test = { core.enable = true; };
          ui = { treesitter-context.enable = true; };
          util = { rest.enable = cfg.util.rest.enable; };
        };
        # TODO:
        # - csharp/dotnet? https://www.reddit.com/r/dotnet/comments/1keiv1m/comment/mqp6yag/
        configFiles = ./lazy/lua;
        plugins = mkMerge [
          { colorscheme = colorschemes.lua."${cfg.colorscheme}"; }
          (mkIf cfg._99.enable { "99" = readFile ./lazy/optional_plugins/99.lua; })
          (mkIf cfg.lang.markdown.zk.enable { "zk" = readFile ./lazy/optional_plugins/zk.lua; })
        ];

        extraPackages = with pkgs; concatLists [
          [
            lua-language-server
            nil
            nixpkgs-fmt
            shfmt
            shellcheck
            statix
            stylua
            tree-sitter
          ]
          (mkIfList cfg.lang.markdown.enable [ marksman ])
          (mkIfList cfg.lang.markdown.zk.enable [ imagemagick mermaid-cli ])
          (mkIfList (cfg.lang.markdown.zk.enable && pkgs.stdenv.isDarwin) [ pngpaste ])
          (mkIfList cfg.lang.typescript.enable [ prettier ])
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

