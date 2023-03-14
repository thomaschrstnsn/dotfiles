{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.vim;
  nvim-test = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-test";
    version = "1.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "klen";
      repo = "nvim-test";
      rev = "4e30d0772a43bd67ff299cfe201964c5bd799d73";
      sha256 = "sha256-iUkBnJxvK71xSqbH8JLm7gwvpiNxfWlAd2+3frNEXXQ=";
    };
    meta.homepage = "https://github.com/klen/nvim-neotest/";
  };
in
{
  options.tc.vim = {
    enable = mkEnableOption "vim";
    ideavim = mkEnableOption "ideavimrc";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ lazygit ripgrep ];

    home.file = mkIf cfg.ideavim {
      ".ideavimrc".source = ./vim/ideavimrc;
    };

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
        autowriteall = true;
      };
      colorschemes.tokyonight = {
        enable = true;
        style = "night";
      };
      plugins = {
        nvim-autopairs.enable = true;
        barbar = { enable = true; };
        comment-nvim = { enable = true; };
        dashboard = { enable = true; };
        gitgutter.enable = true;
        lualine = { enable = true; };
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            eslint.enable = true;
            jsonls.enable = true;
            lua-ls.enable = true;
            rnix-lsp.enable = true;
            tsserver.enable = true;
          };
        };
        lsp-lines = {
          enable = true;
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
            keywordLength = 2;
          };
          snippet.expand = "luasnip";
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
          incrementalSelection = {
            enable = true;
            keymaps = {
              initSelection = "<C-space>";
              nodeIncremental = "<C-space>";
              scopeIncremental = "<nop>";
              nodeDecremental = "<bs>";
            };
          };
        };
        treesitter-context = { enable = true; };
        trouble = { enable = true; };
      };
      maps = {
        normal."-" = "/";
        normal."<leader>e" = {
          silent = true;
          action = "<cmd>NvimTreeFindFileToggle<CR>";
        };
        normal."<esc>" = {
          action = "<cmd>noh<cr><esc>";
          description = "Escape and clear hlsearch";
        };

        normal."<leader>w" = { action = "<cmd>w<cr>"; description = "Save"; };
        normal."<leader>q" = { action = "<cmd>q<cr>"; description = "Quit"; };

        # buffers 
        normal."<leader>bx" = { action = "<cmd>bd<cr>"; description = "Close buffer"; };
        normal."<leader>bX" = {
          action = "<cmd>BufferCloseAllButCurrentOrPinned<cr>";
          description = "Close buffers (except current and pinned)";
        };
        normal."<leader>bj" = { action = "<cmd>BufferPick<cr>"; description = "Pick buffer"; };
        normal."<leader>bp" = { action = "<cmd>BufferPin<cr>"; description = "Pin buffer"; };
        normal."<Tab>" = "<cmd>bn<CR>";
        normal."<S-Tab>" = "<cmd>bp<CR>";

        # lsp
        normal."<leader>la" = { action = "<cmd>Lspsaga code_action<cr>"; description = "Code Actions"; };
        normal."<leader>ld" = { action = "<cmd>Telescope lsp_definitions<cr>"; description = "Definitions"; };
        normal."<leader>lk" = { action = "<cmd>Lspsaga hover_doc<cr>"; description = "Hover Docs"; };
        normal."<leader>lr" = { action = "<cmd>Lspsaga rename<cr>"; description = "Rename"; };
        ## trouble
        normal."<leader>lt" = { action = "<cmd>TroubleToggle<cr>"; description = "Toggle Trouble"; };
        normal."<leader>n" = {
          action = ''<cmd>lua require("trouble").next({skip_groups = true, jump = true});<cr>'';
          description = "Next trouble";
        };
        normal."<leader>N" = {
          action = ''<cmd>lua require("trouble").previous({skip_groups = true, jump = true});<cr>'';
          description = "Previous trouble";
        };
        normal."gR" = {
          action = "<cmd>TroubleToggle lsp_references<cr>";
          description = "references";
        };

        # toggleterm
        normal."<leader>g" = { action = "<cmd>lua Lazygit_toggle()<CR>"; };
        normal."<C-1>" = { action = ":ToggleTerm size=15 direction=horizontal<CR>"; };
        normal."<C-2>" = { action = ":ToggleTerm direction=float<CR>"; };
        # toggle <c-.>

        # Move inside wrapped line
        normal."j" = { action = "v:count == 0 ? 'gj' : 'j'"; silent = true; expr = true; };
        normal."k" = { action = "v:count == 0 ? 'gk' : 'k'"; silent = true; expr = true; };

        normal."<C-S-j>" = { action = "<cmd>m .+1<cr>=="; description = "Move down"; };
        normal."<C-S-k>" = { action = "<cmd>m .-2<cr>=="; description = "Move up"; };
        insert."<C-S-j>" = { action = "<esc><cmd>m .+1<cr>==gi"; description = "Move down"; };
        insert."<C-S-k>" = { action = "<esc><cmd>m .-2<cr>==gi"; description = "Move up"; };
        visual."<C-S-j>" = { action = ":m '>+1<cr>gv=gv"; description = "Move down"; };
        visual."<C-S-k>" = { action = ":m '<-2<cr>gv=gv"; description = "Move up"; };

        # Telescope
        normal."<leader>-" = {
          action = ''<cmd>Telescope current_buffer_fuzzy_find<CR>'';
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
        normal."<leader>:" = {
          action = "<cmd>Telescope command_history<cr>";
          description = "Command History";
        };
        normal."<leader>sk" = {
          action = "<cmd>Telescope keymaps<cr>";
          description = "Key Maps";
        };
        normal."<leader>," = {
          action = "<cmd>Telescope buffers<cr>";
          description = "recent buffers";
        };

        normal."<leader>." = {
          action = "<cmd>@:<CR>";
          description = "Repeat last command";
        };

        #nvim-rest
        normal."<leader>rr" = {
          action = "<cmd>lua require('rest-nvim').run()<CR>";
        };
        normal."<leader>rl" = {
          action = "<cmd>lua require('rest-nvim').last()<CR>";
          description = "Replay last request";
        };
        normal."<leader>rp" = {
          action = "<cmd>lua require('rest-nvim').run(true)<CR>";
          description = "Preview request";
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
        visual."<leader><CR>" = {
          action = ''<cmd>lua FormatSelection()<CR>'';
          description = "Format selection (via LSP)";
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

        # nvim-test
        normal."<leader>uu" = "<cmd>TestLast<CR>";
        normal."<leader>uf" = "<cmd>TestFile<CR>";
        normal."<leader>ur" = "<cmd>TestNearest<CR>";
        normal."<leader>ua" = "<cmd>TestSuite<CR>";

        # LSP (todo, inspiration: https://youtu.be/vdn_pKJUda8?t=3129)
      };
      extraPlugins = with pkgs.vimPlugins; [
        auto-session
        friendly-snippets
        indent-blankline-nvim
        lsp-format-nvim
        luasnip
        nvim-treesitter-context
        nvim-treesitter-textobjects # for queries in mini-ai
        nvim-test
        noice-nvim
        mini-nvim
        plenary-nvim
        rest-nvim
        rust-tools-nvim
        toggleterm-nvim
        which-key-nvim
      ];
      extraConfigLua = builtins.readFile ./vim/init.lua;
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nv = "nvim";
    };
  };
}

