{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.lazyvim;

  fromGitHub = owner: repo: version: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = version;
    src = builtins.fetchGit {
      url = "https://github.com/${owner}/${repo}.git";
      rev = rev;
    };
  };

  mkIfList = cond: xs: if cond then xs else [ ];

in
{
  options.tc.lazyvim = with types; {
    enable = mkEnableOption "lazyvim";
    copilot.enable = mkEnableOption "copilot";
    lang.python.enable = mkEnableOption "python";
    lang.json.enable = mkEnableOption "json" // { default = true; };
    lang.markdown.enable = mkEnableOption "markdown" // { default = true; };
    lang.markdown.notes.enable = mkEnableOption "Full markdown notes taking";
  };

  config = mkIf cfg.enable {
    programs.lazyvim = {
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
          (nvim-treesitter.withPlugins (plugins: attrValues {
            inherit (plugins)
              c_sharp
              rust
              yaml
              zig;
          }))
          blink-cmp
          crates-nvim
          inc-rename-nvim
          lualine-nvim
          multicursor-nvim
          oil-nvim
          rose-pine
          rustaceanvim
          nvim-spider
          nvim-treesitter-context
          mini-surround
          (fromGitHub "ibhagwan" "smartyank.nvim" "2024nov10" "0a4554a4ea4cad73dab0a15e559f2128ca03c7b2")
          undotree
          vim-tmux-navigator
        ]
        (mkIfList cfg.copilot.enable [
          blink-cmp-copilot
          copilot-lua
        ])
        (mkIfList cfg.lang.json.enable [
          SchemaStore-nvim
        ])
        (mkIfList cfg.lang.markdown.enable [
          markdown-preview-nvim
          render-markdown-nvim
        ])
      ];
      # TODO:
      # - lspsaga?
      # - csharp/dotnet? https://www.reddit.com/r/dotnet/comments/1keiv1m/comment/mqp6yag/
      # - dap
      # - neotest
      # - rest
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
          "rose-pine.lua".source = ./lazy/plugins/rose-pine.lua;
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
      ];

      pluginsToDisable = [
        # # example - tokyonight seems to be required
        # {
        #   lazyName = "tokyonight.nvim";
        #   nixName = "tokyonight-nvim";
        # }
      ];
    };

    xdg.configFile = {
      "nvim/lua/config/keymaps.lua".source = ./lazy/config/keymaps.lua;
      "nvim/lua/config/options.lua".source = ./lazy/config/options.lua;
    };

    programs.neovim.withNodeJs = cfg.copilot.enable;

    programs.neovim.extraPackages = with pkgs; concatLists [
      [
        nixpkgs-fmt
        shellcheck
        taplo
      ]
      (mkIfList cfg.lang.markdown.enable [
        marksman
        markdownlint-cli2
      ])
    ];

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
    };
  };
}
