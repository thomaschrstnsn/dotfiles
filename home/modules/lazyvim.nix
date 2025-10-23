{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.lazyvim;

  fromGitHub = owner: repo: version: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    inherit version;
    src = builtins.fetchGit {
      url = "https://github.com/${owner}/${repo}.git";
      inherit rev;
    };
  };

  mkIfList = cond: xs: if cond then xs else [ ];

  kulala-http-grammar = pkgs.tree-sitter.buildGrammar {
    language = "kulala_http";
    version = "6b6e1c8b538cce6654cfc5fb3e4a3acfa316ce57";
    src = pkgs.fetchFromGitHub {
      owner = "mistweaverco";
      repo = "kulala.nvim";
      rev = "6b6e1c8b538cce6654cfc5fb3e4a3acfa316ce57";
      sha256 = "07sgyqnlsm0zgxfg5ir3kmxbhy53h7bw14hiylvixdbp1x3xhn3h";
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
    lang = {
      python.enable = mkEnableOption "python";
      json.enable = mkEnableOption "json" // { default = true; };
      markdown.enable = mkEnableOption "markdown" // { default = true; };
      markdown.notes.enable = mkEnableOption "Full markdown notes taking";
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
            # NOTE: these extras are not super reliable, seems better to create my own installs of dependencies and then use the "plugins/extras.lua"
            # copilot = cfg.copilot.enable;
            # copilot-chat = cfg.copilot.enable;
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
            blink-cmp-copilot
            copilot-lua
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
          (mkIfList cfg.lang.markdown.notes.enable [
            image-nvim
            vimwiki
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
                (optionalString cfg.util.rest.enable ''{ import = "lazyvim.plugins.extras.util.rest" },'')
                ''{ import = "lazyvim.plugins.extras.coding.mini-surround" },''
                ''{ import = "lazyvim.plugins.extras.editor.inc-rename" },''
                ''{ import = "lazyvim.plugins.extras.lang.toml" },''
                ''{ import = "lazyvim.plugins.extras.lang.docker" },''
                "}"
              ]);
          }
          (mkIf cfg.lang.markdown.notes.enable {
            "notes.lua".source = ./lazy/plugins/notes.lua;
          })
          (mkIf cfg.util.rest.enable {
            "rest.lua".source = ./lazy/plugins/rest.lua;
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
          (mkIfList cfg.lang.markdown.notes.enable [ imagemagick ])
          (mkIfList cfg.lang.json.enable [ vscode-langservers-extracted ])
        ];

        extraLuaPackages = ps: concatLists [
          (mkIfList cfg.lang.markdown.notes.enable [
            ps.magick
          ])
        ];
      };
    };


    xdg.configFile = {
      "nvim/lua/config/keymaps.lua".source = ./lazy/config/keymaps.lua;
      "nvim/lua/config/options.lua".source = ./lazy/config/options.lua;
    };


    home.packages = with pkgs; concatLists [
      [
        figlet
        lazygit
        lolcat
        ripgrep
      ]
    ];

    home.shellAliases = {
      vim = "nvim";
      pv = ''nvim -c 'enew' -c 'setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile' -c 'call setline(1, split(getreg("+"), "\n"))' '';
    };
  };
}

