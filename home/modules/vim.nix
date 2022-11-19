{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.vim;
in
{
  options.tc.vim = {
    enable = mkEnableOption "vim";
  };

  config = mkIf (cfg.enable) {
    programs.nixvim = {
      enable = true;
      globals.mapleader = " ";
      options = {
        number = true;
        relativenumber = true;

        shiftwidth = 4;
        tabstop = 4;
        scrolloff = 25;

        clipboard = "unnamedplus";

        autoindent = true;
        backspace = "indent,eol,start";

      };
      colorschemes.gruvbox.enable = true;
      plugins = {
        bufferline = {
          enable = true;
          showCloseIcon = false;
          separatorStyle = "thin";
        };
        gitgutter.enable = true;
        lualine = { enable = true; };
        lsp = {
          enable = true;
          servers = {
            rnix-lsp.enable = true;
          };
        };
        lspsaga = {
          enable = true;
          icons = {
            codeAction = "";

          };
          signs = {
            error = "";
            hint = "";
            info = "";
            warning = "";
          };
        };
        nix.enable = true;
        nvim-cmp = {
          enable = true;
        };
        nvim-tree = {
          enable = true;
          disableNetrw = true;
        };
        project-nvim.enable = true;
        telescope = {
          enable = true;
          extensions.project-nvim.enable = true;
        };
        treesitter = {
          enable = true;
          nixGrammars = true;
        };
      };
      maps = {
        normal."-" = "/";
        normal."<leader>e" = {
          silent = true;
          action = "<cmd>NvimTreeFindFileToggle<CR>";
        };
        normal."<leader><leader>" = "<cmd>nohl<CR>";
        normal."<Tab>" = "<cmd>bn<CR>";
        normal."<S-Tab>" = "<cmd>bp<CR>";
      };
      extraPlugins = with pkgs.vimPlugins; [
        which-key-nvim
      ];
      extraConfigLua = ''
        local __which_key = require('which-key')
        __which_key.setup{['show_help'] = true,['window'] = {['border'] = 'single'}}
      '';
    };
    programs.neovim.vimAlias = true;
    programs.neovim.viAlias = true;
  };
}
