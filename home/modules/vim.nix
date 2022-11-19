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

        ignorecase = true;
        cursorline = true;
      };
      colorschemes.gruvbox.enable = true;
      plugins = {
        nvim-autopairs.enable = true;
        bufferline = {
          enable = true;
          showCloseIcon = false;
          separatorStyle = "thin";
        };
        comment-nvim = {enable= true;};
        # dashboard = {enable = true; };
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
        null-ls = {
          enable = true;
          sources = {
            diagnostics.shellcheck.enable = true;
            formatting.nixfmt.enable = true;
          };
        };
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
        
        # keep selection when indenting
        visual.">" = {
          noremap = true;
          action = ">gv";
        };
        visual."<" = {
          noremap = true;
          action = "<gv";
        };

      };
      extraPlugins = with pkgs.vimPlugins; [
        nvim-treesitter-context
        which-key-nvim
      ];
      extraConfigLua = ''
        local __which_key = require('which-key')

        __which_key.register({
          ['b'] = {['b'] = {'<cmd>BufferLineCyclePrev<cr>','Previous'},
                   ['j'] = {'<cmd>BufferLinePick<cr>','Jump'},
                   ['name'] = '+Buffers',
                   ['w'] = {'<cmd>bd<cr>','Wipeout'}},
          ['f'] = {['f'] = {'<cmd>Telescope find_files<cr>','Find File'},
                   ['name'] = '+Files'},
          ['l'] = {['a'] = {'<cmd>Lspsaga code_action<cr>','Code Actions'},
          ['d'] = {'<cmd>Telescope lsp_definitions<cr>','Definitions'},
                   ['k'] = {'<cmd>Lspsaga hover_doc<cr>','Hover Documentation'},
                   ['name'] = '+LSP',
                   ['r'] = {'<cmd>Lspsaga rename<cr>','Rename'},
                   ['t'] = {'<cmd>TroubleToggle<cr>','Toggle Trouble'}},
          ['p'] = {'<cmd>Telescope projects<cr>','Open Project'},
          ['q'] = {'<cmd>q<cr>','Quit'},
          ['r'] = {'<cmd>TodoTrouble<cr>','List all project todos'},
          ['t'] = {['name'] = '+Train',
                   ['o'] = {'<cmd>TrainTextObj<cr>','Train for movements related to text objects'},
                   ['u'] = {'<cmd>TrainUpDown<cr>','Train for movements up and down'},
                   ['w'] = {'<cmd>TrainWord<cr>','Train for movements related to words'}},
          ['w'] = {'<cmd>w<cr>','Save'}}, 
          {['mode'] = 'n',['prefix'] = '<leader>'})

        __which_key.setup{['show_help'] = true,['window'] = {['border'] = 'single'}}
      '';
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nv = "nvim";
    };
  };
}
