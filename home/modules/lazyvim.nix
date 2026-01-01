{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.lazyvim;

  fromGitHub = owner: repo: version: rev: fromGitHub' owner repo version rev { };
  fromGitHubNoCheck = owner: repo: version: rev: fromGitHub' owner repo version rev { doCheck = false; };
  fromGitHub' = owner: repo: version: rev: extra: pkgs.vimUtils.buildVimPlugin
    ({
      pname = "${lib.strings.sanitizeDerivationName repo}";
      inherit version;
      src = builtins.fetchGit
        {
          url = "https://github.com/${owner}/${repo}.git";
          inherit rev;
        };
    } // extra);

  mkIfList = cond: xs: if cond then xs else [ ];

  kulala-http-grammar = pkgs.tree-sitter.buildGrammar {
    language = "kulala_http";
    version = "5.3.3 ";
    src = pkgs.fetchFromGitHub {
      owner = "mistweaverco";
      repo = "kulala.nvim";
      rev = "ab3effad17d5dbb4d5d34b6289fa4dc97155045c";
      sha256 = "sha256-40grZKIl74sbk3L+VJpuvPQqajY3CGeLv8eKbo4wIZU";
    };
    location = "lua/tree-sitter";
    generate = false;
  };
  colorschemes = {
    pkgs = with pkgs.vimPlugins; {
      everforest = [ everforest ];
      kanagawa = [ kanagawa-nvim ];
      rose-pine = [ rose-pine ];
      tokyonight = [ ];
    };
    lua = {
      everforest = { "everforest.lua".source = ./lazy/plugins/everforest.lua; };
      kanagawa = { "kanagawa.lua".source = ./lazy/plugins/kanagawa.lua; };
      rose-pine = { "rose-pine.lua".source = ./lazy/plugins/rose-pine.lua; };
      tokyonight = { };
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
        extras = {
          ai = {
            copilot.enable = cfg.copilot.enable;
            copilot-chat.enable = cfg.copilot.enable;
          };
          lang = {
            nix.enable = true;
            python.enable = cfg.lang.python.enable;
          };
        };
        plugins = with pkgs.vimPlugins; concatLists [
          [
            (nvim-treesitter.withPlugins (plugins: attrValues
              {
                inherit (plugins)
                  c_sharp
                  rust
                  yaml
                  zig;
                kulala_http = kulala-http-grammar;
              }))
            blink-cmp
            crates-nvim
            inc-rename-nvim
            lualine-nvim
            multicursor-nvim
            oil-nvim
            rustaceanvim
            nvim-spider
            nvim-treesitter-context
            mini-surround
            (fromGitHub "ibhagwan" "smartyank.nvim" "2024nov10" "0a4554a4ea4cad73dab0a15e559f2128ca03c7b2")
            undotree
            vim-tmux-navigator
          ]
          colorschemes.pkgs."${cfg.colorscheme}"
          (mkIfList cfg.copilot.enable [
            blink-copilot
          ])
          (mkIfList cfg.lang.json.enable [
            SchemaStore-nvim
          ])
          (mkIfList cfg.lang.python.enable [
            (fromGitHub "linux-cultist" "venv-selector.nvim" "2025sept" "2b49d1f8b8fcf5cfbd0913136f48f118225cca5d")
          ])
          (mkIfList cfg.lang.markdown.enable [
            markdown-preview-nvim
            render-markdown-nvim
          ])
          (mkIfList cfg.lang.markdown.zk.enable [
            autolist-nvim
            image-nvim
            img-clip-nvim
            # zk-nvim
            (fromGitHubNoCheck "zk-org" "zk-nvim" "v0.4.6" "8df80d0dc2d66e53b08740361a600746a6e4edcf") # workaround for failing requirecheck
          ])
          (mkIfList cfg.lang.typescript.enable [
            nvim-vtsls
          ])
          (mkIfList cfg.util.rest.enable [
            kulala-nvim
          ])
        ];
        # TODO:
        # - lspsaga?
        # - csharp/dotnet? https://www.reddit.com/r/dotnet/comments/1keiv1m/comment/mqp6yag/
        # - dap
        # - neotest
        # - harpoon
        # - auto-dark-mode vs darklight
        # - femaco
        # - otter
        pluginsFile = mkMerge [
          {
            "editor.lua".source = ./lazy/plugins/editor.lua;
            "blink.lua".source = ./lazy/plugins/blink.lua;
            "lsp.lua".source = ./lazy/plugins/lsp.lua;
            "lint.lua".source = ./lazy/plugins/lint.lua;
            "lualine.lua".source = ./lazy/plugins/lualine.lua;
            "multicursor.lua".source = ./lazy/plugins/multicursor.lua;
            "mini-pairs.lua".source = ./lazy/plugins/mini-pairs.lua;
            "oil.lua".source = ./lazy/plugins/oil.lua;
            "rust.lua".source = ./lazy/plugins/rust.lua;
            "smartyank.lua".source = ./lazy/plugins/smartyank.lua;
            "snacks.lua".source = ./lazy/plugins/snacks.lua;
            "spider.lua".source = ./lazy/plugins/spider.lua;
            "treesitter-context.lua".source = ./lazy/plugins/treesitter-context.lua;
            "extras.lua".text = concatStringsSep "\n"
              (filter (s: s != "") [
                "return {"
                (optionalString cfg.copilot.enable ''{ import = "lazyvim.plugins.extras.ai.copilot" },'')
                (optionalString cfg.lang.json.enable ''{ import = "lazyvim.plugins.extras.lang.json" },'')
                (optionalString cfg.lang.markdown.enable ''{ import = "lazyvim.plugins.extras.lang.markdown" },'')
                (optionalString cfg.lang.typescript.enable ''{ import = "lazyvim.plugins.extras.lang.typescript" },'')
                (optionalString cfg.util.rest.enable ''{ import = "lazyvim.plugins.extras.util.rest" },'')
                ''{ import = "lazyvim.plugins.extras.coding.mini-surround" },''
                ''{ import = "lazyvim.plugins.extras.editor.inc-rename" },''
                ''{ import = "lazyvim.plugins.extras.lang.toml" },''
                ''{ import = "lazyvim.plugins.extras.lang.docker" },''
                "}"
              ]);
          }
          (mkIf cfg.lang.markdown.zk.enable {
            "zk.lua".source = ./lazy/plugins/zk.lua;
          })
          (mkIf cfg.util.rest.enable {
            "rest.lua".source = ./lazy/plugins/rest.lua;
          })
          (mkIf cfg.gh.enable {
            "gh.lua".source = ./lazy/plugins/gh.lua;
          })
          colorschemes.lua."${cfg.colorscheme}"
        ];

        pluginsToDisable = [
          # # example - tokyonight seems to be required
          # {
          #   lazyName = "tokyonight.nvim";
          #   nixName = "tokyonight-nvim";
          # }
        ];
      };

      neovim = {
        withNodeJs = cfg.copilot.enable;

        extraPackages = with pkgs; concatLists [
          [
            nixpkgs-fmt
            shellcheck
            statix
            taplo
          ]
          (mkIfList cfg.lang.markdown.enable [
            marksman
            markdownlint-cli2
          ])
          (mkIfList cfg.lang.markdown.zk.enable [ imagemagick ])
          (mkIfList (cfg.lang.markdown.zk.enable && pkgs.stdenv.isDarwin) [ pngpaste ])
          (mkIfList cfg.lang.json.enable [ vscode-langservers-extracted ])
          (mkIfList cfg.lang.typescript.enable [ typescript-language-server ])
        ];

        extraLuaPackages = ps: concatLists [
          (mkIfList cfg.lang.markdown.zk.enable [
            ps.magick
          ])
        ];
      };
    };


    xdg.configFile = {
      "nvim/lua/config/keymaps.lua".source = ./lazy/config/keymaps.lua;
      "nvim/lua/config/options.lua".source = ./lazy/config/options.lua;
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

