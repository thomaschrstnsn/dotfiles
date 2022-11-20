{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.vim;
in
{
  options.tc.vim = { enable = mkEnableOption "vim"; };

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
        smartcase = true;

        cursorline = true;

        undofile = true;
        swapfile = false;
        writebackup = false;
      };
      colorschemes.gruvbox.enable = true;
      plugins = {
        nvim-autopairs.enable = true;
        bufferline = {
          enable = true;
          showCloseIcon = false;
          separatorStyle = "thin";
        };
        comment-nvim = { enable = true; };
        dashboard = {enable = true; };
        gitgutter.enable = true;
        lualine = { enable = true; };
        lsp = {
          enable = true;
          servers = { rnix-lsp.enable = true; };
        };
        lspsaga = {
          enable = true;
          icons = { codeAction = ""; };
          signs = {
            error = "";
            hint = "";
            info = "";
            warning = "";
          };
        };
        nix.enable = true;
        notify.enable = true;
        null-ls = {
          enable = true;
          sources = {
            diagnostics.shellcheck.enable = true;
            # formatting.nixfmt.enable = true; # disabled since rnix also offers this - decide how to avoid the conflict
          };
        };
        nvim-cmp = { enable = true; };
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

        normal."<leader><CR>" = "<cmd>lua vim.lsp.buf.format {async = true;}<CR>";
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

        -- nvim-tree is also there in modified buffers so this function filter it out
        local modifiedBufs = function(bufs)
            local t = 0
            for k,v in pairs(bufs) do
                if v.name:match("NvimTree_") == nil then
                    t = t + 1
                end
            end
            return t
        end

        vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
                if #vim.api.nvim_list_wins() == 1 and
                vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil and
                modifiedBufs(vim.fn.getbufinfo({bufmodified = 1})) == 0 then
                    vim.cmd "quit"
                end
            end
        })

        local db = require('dashboard')
        db.custom_center = {
            {icon = '  ',
            desc = 'Recently latest session                  ',
            shortcut = 'SPC s l',
            action ='SessionLoad'},
            {icon = '  ',
            desc = 'Recently opened files                   ',
            action =  'DashboardFindHistory',
            shortcut = 'SPC f h'},
            {icon = '  ',
            desc = 'Find  File                              ',
            action = 'Telescope find_files find_command=rg,--hidden,--files',
            shortcut = 'SPC f f'},
            {icon = '  ',
            desc ='File Browser                            ',
            action =  'Telescope file_browser',
            shortcut = 'SPC f b'},
            {icon = '  ',
            desc = 'Find  word                              ',
            action = 'Telescope live_grep',
            shortcut = 'SPC f w'},
          }
      '';
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nv = "nvim";
    };
  };
}
