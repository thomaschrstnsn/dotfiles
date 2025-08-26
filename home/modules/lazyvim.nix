{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.lazyvim;

  fromGitHub = repo: version: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = version;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
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
          oil-nvim
          rose-pine
          rustaceanvim
          nvim-spider
          nvim-treesitter-context
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
      ];
      pluginsFile = {
        "editor.lua".source = ./lazy/plugins/editor.lua;
        "blink.lua".source = ./lazy/plugins/blink.lua;
        "lsp.lua".source = ./lazy/plugins/lsp.lua;
        "oil.lua".source = ./lazy/plugins/oil.lua;
        "rose-pine.lua".source = ./lazy/plugins/rose-pine.lua;
        "rust.lua".source = ./lazy/plugins/rust.lua;
        "snacks.lua".source = ./lazy/plugins/snacks.lua;
        "spider.lua".source = ./lazy/plugins/spider.lua;
        "treesitter-context.lua".source = ./lazy/plugins/treesitter-context.lua;
        "extras.lua".text = concatStringsSep "\n"
          (filter (s: s != "") [
            "return {"
            (optionalString cfg.copilot.enable ''{ import = "lazyvim.plugins.extras.ai.copilot" },'')
            (optionalString cfg.lang.json.enable ''{ import = "lazyvim.plugins.extras.lang.json" },'')
            ''{ import = "lazyvim.plugins.extras.editor.inc-rename" },''
            "}"
          ]);
      };

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

    home.packages = with pkgs; [
      figlet
      lazygit
      lolcat
      nixpkgs-fmt
      ripgrep
      taplo
    ];

    home.shellAliases = {
      vim = "nvim";
    };
  };
}
