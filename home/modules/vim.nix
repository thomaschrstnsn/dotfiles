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
        scrolloff = 49;

        clipboard = "unnamedplus";

        autoindent = true;
        backspace = "indent,eol,start";

        ignorecase = true;
        smartcase = true;

        cursorline = true;

        undofile = true;
        swapfile = false;
        writebackup = false;

        breakindent = true;
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
        dashboard = { enable = true; };
        gitgutter.enable = true;
        lualine = { enable = true; };
        lsp = {
          enable = true;
          servers = {
            eslint.enable = true;
            jsonls.enable = true;
            rnix-lsp.enable = true;
            tsserver.enable = true;
          };
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
          # todo: format on save, see https://youtu.be/vdn_pKJUda8?t=3912)
        };
        nvim-cmp = {
          enable = true;
          completion = {
            completeopt = "menu,menuone,noselect";
            keyword_length = 2;
          };
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end
          '';
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = ''cmp.mapping(function(fallback)
                -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
                if (cmp.visible()) then
                  local entry = cmp.get_selected_entry()
                  if not entry then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                  else
                    cmp.confirm()
                  end
                else
                  fallback()
                end
              end, {"i","s",}) '';
            "<Up>" = "cmp.mapping.select_prev_item()";
            "<Down>" = "cmp.mapping.select_next_item()";
            "<C-Space>" = "cmp.mapping.complete()";
          };
          sources = [
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "treesitter"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
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

        # Telescope
        normal."<leader>-" = {
          action = ''<cmd>lua require("telescope.builtin").current_buffer_fuzzy_find { }<CR>'';
          description = "find in current buffer";
        };
        normal."<leader>ff" = {
          action = ''<cmd>Telescope find_files<CR>'';
          description = "find file";
        };
        normal."<leader>fs" = {
          action = ''<cmd>Telescope live_grep<CR>'';
          description = "find word";
        };
        normal."<leader>fb" = {
          action = ''<cmd>Telescope buffers<CR>'';
          description = "find buffer";
        };
        normal."<leader>fh" = {
          action = ''<cmd>Telescope help_tags<CR>'';
          description = "find help";
        };

        # keep selection when indenting
        visual.">" = {
          noremap = true;
          action = ">gv";
        };
        visual."<" = {
          noremap = true;
          action = "<gv";
        };

        normal."<leader><CR>" = {
          action = "<cmd>lua vim.lsp.buf.format {async = true;}<CR>";
          description = "Format buffer (via LSP)";
        };

        # splits
        normal."<leader>sv" = {
          action = "<C-w>v";
          description = "split vertically";
        };
        normal."<leader>sh" = {
          action = "<C-w>s";
          description = "split horizontally";
        };
        normal."<leader>se" = {
          action = "<C-w>=";
          description = "even splits";
        };
        normal."<leader>sx" = {
          action = "<cmd>:close<CR>";
          description = "close current window split";
        };
        normal."<C-h>" = "<cmd>wincmd h<CR>";
        normal."<C-j>" = "<cmd>wincmd j<CR>";
        normal."<C-k>" = "<cmd>wincmd k<CR>";
        normal."<C-l>" = "<cmd>wincmd l<CR>";

        # LSP (todo, inspiration: https://youtu.be/vdn_pKJUda8?t=3129)
      };
      extraPlugins = with pkgs.vimPlugins; [
        auto-session
        friendly-snippets
        indent-blankline-nvim
        lsp-format-nvim
        luasnip
        nvim-treesitter-context
        rust-tools-nvim
        which-key-nvim
      ];
      extraConfigLua = ''
        local __which_key = require('which-key')

        __which_key.register({
          ['b'] = {['b'] = {'<cmd>BufferLineCyclePrev<cr>','Previous'},
                   ['j'] = {'<cmd>BufferLinePick<cr>','Jump'},
                   ['name'] = '+Buffers',
                   ['w'] = {'<cmd>bd<cr>','Wipeout'}},
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
            {icon = '  ',
            desc = 'Find  word                              ',
            action = 'Telescope live_grep',
            shortcut = 'SPC f s'},
          }

        require("auto-session").setup {
          log_level = "error"
        }

        require("luasnip/loaders/from_vscode").lazy_load()

        local rt = require("rust-tools")

        rt.setup({
          server = {
            on_attach = function(_, bufnr)
              -- Hover actions
              vim.keymap.set("n", "gh", rt.hover_actions.hover_actions, { buffer = bufnr })
              -- Code action groups
              vim.keymap.set("n", "<Leader>.", rt.code_action_group.code_action_group, { buffer = bufnr })
            end,
          },
        })

        require("lsp-format").setup {}
        local on_attach = function(client)
          require("lsp-format").on_attach(client)
        end
        require("lspconfig").rust_analyzer.setup { on_attach = on_attach }
        require("lspconfig").rnix.setup { on_attach = on_attach }

        -- [[ Highlight on yank ]]
        -- See `:help vim.highlight.on_yank()`
        local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
        vim.api.nvim_create_autocmd('TextYankPost', {
          callback = function()
            vim.highlight.on_yank()
          end,
          group = highlight_group,
          pattern = '*',
        })

        require("indent_blankline").setup {
            space_char_blankline = " ",
            show_current_context = true,
            show_current_context_start = true,
            char = '┊',
            show_trailing_blankline_indent = false,
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
