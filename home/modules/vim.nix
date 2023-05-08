{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.vim;
  wslCfg = config.tc.wsl;

  fromGitHub = repo: version: rev: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = version;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
  };

  treesitterGrammars = grammarSet: package:
    if grammarSet == "all"
    then package.passthru.allGrammars
    else if grammarSet == "slim"
    then
      with package.passthru.builtGrammars; [
        bash
        diff
        dockerfile
        git_rebase
        git_config
        gitcommit
        gitignore
        jq
        json
        lua
        markdown
        markdown_inline
        nix
        yaml
      ]
    else error "bahh";
in
{
  options.tc.vim = with types; {
    enable = mkEnableOption "vim";
    ideavim = mkEnableOption "ideavimrc";
    gitui = mkOption {
      type = enum [ "lazygit" "gitui" ];
      description = "Which gitui to use inside nvim";
      default = "lazygit";
    };
    treesitter = {
      package = mkOption {
        type = types.package;
        default = pkgs.vimPlugins.nvim-treesitter;
        description = "Plugin to use for nvim-treesitter. If using nixGrammars, it should include a `withPlugins` function";
      };
      grammarPackageSet = mkOption {
        type = with types; enum [ "all" "slim" ];
        default = "all";
        description = "all or slim (intended for servers)";
      };
    };
    lsp.servers.javascript = mkOption {
      type = types.bool;
      default = true;
      description = "javascript lsp enabled";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; let
      gitpkg = if cfg.gitui == "lazygit" then lazygit else gitui;
    in
    [ gitpkg ripgrep ];

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
        barbar = { enable = true; };
        comment-nvim = { enable = true; };
        gitgutter.enable = true;
        lualine = { enable = true; };
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            eslint.enable = cfg.lsp.servers.javascript;
            jsonls.enable = true;
            lua-ls.enable = true;
            rnix-lsp.enable = true;
            tsserver.enable = cfg.lsp.servers.javascript;
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
        nvim-autopairs.enable = true;
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
            { name = "crates"; }
          ];
        };
        nvim-tree = {
          enable = true;
          disableNetrw = true;
          actions.openFile.quitOnOpen = true;
        };
        project-nvim.enable = true;
        telescope = {
          enable = true;
          extensions.project-nvim.enable = true;
        };
        treesitter = {
          enable = true;
          nixGrammars = true;
          package = cfg.treesitter.package;
          grammarPackages = treesitterGrammars cfg.treesitter.grammarPackageSet cfg.treesitter.package;
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
          desc = "Escape and clear hlsearch";
        };

        normal."<leader>w" = { action = "<cmd>w<cr>"; desc = "Save"; };
        normal."<leader>q" = { action = "<cmd>q<cr>"; desc = "Quit"; };

        # buffers 
        normal."<leader>bx" = { action = "<cmd>bd<cr>"; desc = "Close buffer"; };
        normal."<leader>bX" = {
          action = "<cmd>BufferCloseAllButCurrentOrPinned<cr>";
          desc = "Close buffers (except current and pinned)";
        };
        normal."<leader>bj" = { action = "<cmd>BufferPick<cr>"; desc = "Pick buffer"; };
        normal."<leader>bp" = { action = "<cmd>BufferPin<cr>"; desc = "Pin buffer"; };
        normal."<Tab>" = "<cmd>bn<CR>";
        normal."<S-Tab>" = "<cmd>bp<CR>";

        # lsp
        normal."<leader>la" = { action = "<cmd>Lspsaga code_action<cr>"; desc = "Code Actions"; };
        normal."<leader>ld" = { action = "<cmd>Telescope lsp_definitions<cr>"; desc = "Definitions"; };
        normal."K" = { action = "<cmd>Lspsaga hover_doc<cr>"; desc = "Hover Docs"; };
        normal."<leader>lr" = { action = "<cmd>Lspsaga rename<cr>"; desc = "Rename"; };
        ## trouble
        normal."<leader>lt" = { action = "<cmd>TroubleToggle<cr>"; desc = "Toggle Trouble"; };
        normal."<leader>n" = {
          action = ''<cmd>lua require("trouble").next({skip_groups = true, jump = true});<cr>'';
          desc = "Next trouble";
        };
        normal."<leader>N" = {
          action = ''<cmd>lua require("trouble").previous({skip_groups = true, jump = true});<cr>'';
          desc = "Previous trouble";
        };
        normal."gR" = {
          action = "<cmd>TroubleToggle lsp_references<cr>";
          desc = "references";
        };

        # toggleterm
        normal."<leader>g" = { action = "<cmd>lua Gitui_toggle()<CR>"; };
        normal."<leader>th" = { action = ":ToggleTerm direction=horizontal<CR>"; };
        normal."<leader>tv" = { action = ":ToggleTerm direction=vertical<CR>"; };
        normal."<leader>tf" = { action = ":ToggleTerm direction=float<CR>"; };
        # toggle is \\

        # Move inside wrapped line
        normal."j" = { action = "v:count == 0 ? 'gj' : 'j'"; silent = true; expr = true; };
        normal."k" = { action = "v:count == 0 ? 'gk' : 'k'"; silent = true; expr = true; };

        normal."<C-S-j>" = { action = "<cmd>m .+1<cr>=="; desc = "Move down"; };
        normal."<C-S-k>" = { action = "<cmd>m .-2<cr>=="; desc = "Move up"; };
        insert."<C-S-j>" = { action = "<esc><cmd>m .+1<cr>==gi"; desc = "Move down"; };
        insert."<C-S-k>" = { action = "<esc><cmd>m .-2<cr>==gi"; desc = "Move up"; };
        visual."<C-S-j>" = { action = ":m '>+1<cr>gv=gv"; desc = "Move down"; };
        visual."<C-S-k>" = { action = ":m '<-2<cr>gv=gv"; desc = "Move up"; };

        # Telescope
        normal."<leader>-" = {
          action = ''<cmd>Telescope current_buffer_fuzzy_find<CR>'';
          desc = "find in current buffer";
        };
        normal."<leader>ff" = {
          action = ''<cmd>Telescope find_files<CR>'';
          desc = "find file";
        };
        normal."<leader>fs" = {
          action = ''<cmd>Telescope live_grep<CR>'';
          desc = "find word";
        };
        normal."<leader>fb" = {
          action = ''<cmd>Telescope buffers<CR>'';
          desc = "find buffer";
        };
        normal."<leader>fh" = {
          action = ''<cmd>Telescope help_tags<CR>'';
          desc = "find help";
        };
        normal."<leader>:" = {
          action = "<cmd>Telescope command_history<cr>";
          desc = "Command History";
        };
        normal."<leader>sk" = {
          action = "<cmd>Telescope keymaps<cr>";
          desc = "Key Maps";
        };
        normal."<leader>," = {
          action = "<cmd>Telescope buffers<cr>";
          desc = "recent buffers";
        };

        normal."<leader>." = {
          action = "<cmd>@:<CR>";
          desc = "Repeat last command";
        };

        #nvim-rest
        # normal."<leader>rr" = {
        #   action = "<cmd>lua require('rest-nvim').run()<CR>";
        # };
        # normal."<leader>rl" = {
        #   action = "<cmd>lua require('rest-nvim').last()<CR>";
        #   desc = "Replay last request";
        # };
        # normal."<leader>rp" = {
        #   action = "<cmd>lua require('rest-nvim').run(true)<CR>";
        #   desc = "Preview request";
        # };

        # rust-tools-nvim
        normal."<leader>r" = {
          action = "<cmd>lua require('rust-tools').runnables.runnables()<CR>";
          desc = "Rust Runnables";
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
          desc = "Format buffer (via LSP)";
        };
        visual."<leader><CR>" = {
          action = ''<cmd>lua FormatSelection()<CR>'';
          desc = "Format selection (via LSP)";
        };

        # splits
        normal."<leader>sv" = {
          action = "<C-w>v";
          desc = "split vertically";
        };
        normal."<leader>sh" = {
          action = "<C-w>s";
          desc = "split horizontally";
        };
        normal."<leader>se" = {
          action = "<C-w>=";
          desc = "even splits";
        };
        normal."<leader>sx" = {
          action = "<cmd>:close<CR>";
          desc = "close current window split";
        };
        normal."<C-h>" = "<cmd>wincmd h<CR>";
        normal."<C-j>" = "<cmd>wincmd j<CR>";
        normal."<C-k>" = "<cmd>wincmd k<CR>";
        normal."<C-l>" = "<cmd>wincmd l<CR>";

        # crates-nvim
        normal."<leader>ct" = ":lua require('crates').toggle()<cr>";
        normal."<leader>cr" = ":lua require('crates').reload()<cr>";

        normal."<leader>cv" = ":lua require('crates').show_versions_popup()<cr>";
        normal."<leader>cf" = ":lua require('crates').show_features_popup()<cr>";
        normal."<leader>cd" = ":lua require('crates').show_dependencies_popup()<cr>";

        normal."<leader>cu" = ":lua require('crates').update_crate()<cr>";
        visual."<leader>cu" = ":lua require('crates').update_crates()<cr>";
        normal."<leader>ca" = ":lua require('crates').update_all_crates()<cr>";
        normal."<leader>cU" = ":lua require('crates').upgrade_crate()<cr>";
        visual."<leader>cU" = ":lua require('crates').upgrade_crates()<cr>";
        normal."<leader>cA" = ":lua require('crates').upgrade_all_crates()<cr>";

        normal."<leader>cH" = ":lua require('crates').open_homepage()<cr>";
        normal."<leader>cR" = ":lua require('crates').open_repository()<cr>";
        normal."<leader>cD" = ":lua require('crates').open_documentation()<cr>";
        normal."<leader>cC" = ":lua require('crates').open_crates_io()<cr>";


        # nvim-test
        normal."<leader>uu" = "<cmd>TestLast<CR>";
        normal."<leader>uf" = "<cmd>TestFile<CR>";
        normal."<leader>ur" = "<cmd>TestNearest<CR>";
        normal."<leader>ua" = "<cmd>TestSuite<CR>";

        # LSP (todo, inspiration: https://youtu.be/vdn_pKJUda8?t=3129)
      };
      extraPlugins = with pkgs.vimPlugins; [
        auto-session
        crates-nvim
        friendly-snippets
        git-blame-nvim
        indent-blankline-nvim
        lsp-format-nvim
        luasnip
        (fromGitHub "chrisgrieser/nvim-spider" "head" "f0fd485bd8e413623b8804ab29cab63e0d35fb2a")
        nvim-treesitter-context
        nvim-treesitter-textobjects # for queries in mini-ai
        (fromGitHub "klen/nvim-test" "1.3.0" "4e30d0772a43bd67ff299cfe201964c5bd799d73")
        noice-nvim
        (fromGitHub "echasnovski/mini.nvim" "0.8.0" "889be69623395ad183ae6f3c21c8efe006350226")
        plenary-nvim
        rest-nvim
        rust-tools-nvim
        (fromGitHub "ibhagwan/smartyank.nvim" "feb25" "7e3905578f646503525b2f7018b8afd17861018c")
        toggleterm-nvim
        vim-tmux-navigator
        which-key-nvim
      ];
      extraConfigLua = replaceStrings [ "$GITUI$" ] [ cfg.gitui ] (builtins.readFile ./vim/init.lua);
      extraConfigVim =
        if wslCfg.enable
        then ''
          let g:clipboard = {
                      \   'name': 'WslClipboard',
                      \   'copy': {
                      \      '+': 'clip.exe',
                      \      '*': 'clip.exe',
                      \    },
                      \   'paste': {
                      \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                      \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                      \   },
                      \   'cache_enabled': 0,
                      \ }
        '' else "";
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nv = "nvim";
    };
  };
}

