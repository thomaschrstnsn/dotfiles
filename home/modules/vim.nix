{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.vim;
  wslCfg = config.tc.wsl;

  fromGitHub = repo: version: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = version;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
  };

  /* Import a luafile inside of a vimrc.

    Example:
    mkLuaFile "foo.lua"
    => "lua << EOF dofile(\"foo.lua\") EOF"
  */
  mkLuaFile = file: ''
    lua << EOF
      dofile("${file}")
    EOF
  '';

  /* Generate a lua section for a vimrc file.

    Example:
    mkLua "print('hello world')"
    => "lua << EOF print('hello world') EOF"
  */
  mkLua = lua: ''
    lua << EOF
      ${lua}
    EOF
  '';

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
    lsp.servers.omnisharp = mkOption {
      type = types.bool;
      default = false;
      description = "omnisharp lsp enabled";
    };
    lsp.servers.csharp = mkOption {
      type = types.bool;
      default = false;
      description = "csharp lsp enabled";
    };
    lsp.servers.javascript = mkOption {
      type = types.bool;
      default = false;
      description = "javascript lsp enabled";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      lazygit
      ripgrep
    ];

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

        signcolumn = "yes";

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
      colorschemes.kanagawa =
        let variation = "wave"; # wave, dragon, lotus
        in
        {
          enable = true;
          theme = variation;
          background.dark = variation;
          transparent = true;
        };
      luaLoader.enable = true;
      plugins = {
        auto-session = {
          enable = true;
          logLevel = "error";
        };
        barbar = { enable = true; };
        comment-nvim = { enable = true; };
        crates-nvim = { enable = true; };
        gitblame.enable = true;
        gitgutter.enable = true;
        harpoon = {
          enable = true;
          keymaps = {
            addFile = "<leader>ja";
            toggleQuickMenu = "<leader>jj";
            navFile = {
              "1" = "<C-f>";
              "2" = "<C-d>";
              "3" = "<C-s>";
              "4" = "<C-a>";
            };
            navNext = "<C-]>";
            navPrev = "<C-[>";
          };
        };
        indent-blankline = {
          enable = true;
          scope = {
            enabled = true;
            showStart = true;
          };
          whitespace.removeBlanklineTrail = false;
        };
        illuminate = { enable = true; };
        leap = {
          enable = true;
          addDefaultMappings = false;
        };
        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            csharp-ls.enable = cfg.lsp.servers.csharp;
            eslint.enable = cfg.lsp.servers.javascript;
            jsonls.enable = cfg.lsp.servers.javascript;
            lua-ls.enable = true;
            omnisharp = {
              enable = cfg.lsp.servers.omnisharp;
              settings = {
                enableImportCompletion = true;
                enableRoslynAnalyzers = true;
              };
            };
            rnix-lsp.enable = true;
            tsserver.enable = cfg.lsp.servers.javascript;
          };
        };
        lsp-lines = {
          enable = true;
          currentLine = true;
        };
        lsp-format = {
          enable = true;
        };
        lspsaga = {
          enable = true;
          lightbulb.virtualText = false;
        };
        lualine = { enable = true; };
        mini = {
          enable = true;
          modules = {
            indentscope = { };
            trailspace = { };
          };
        };
        nix.enable = true;
        notify.enable = true;
        none-ls = {
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
        rust-tools = {
          enable = true;
        };
        spider = {
          enable = true;
          keymaps.motions = {
            w = "w";
            e = "e";
            b = "b";
            ge = "ge";
          };
        };
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
              initSelection = "<leader>v";
              nodeIncremental = "<leader>v";
              scopeIncremental = "<nop>";
              nodeDecremental = "<bs>";
            };
          };
        };
        tmux-navigator.enable = true;
        treesitter-context.enable = true;
        treesitter-textobjects.enable = true;
        trouble = { enable = true; };
        which-key = {
          enable = true;
          window.border = "single";
        };
      };
      keymaps = [
        {
          key = "<leader>e";
          action = "<cmd>NvimTreeFindFileToggle<CR>";
          options = {
            silent = true;
            desc = "nvimtree toggle";
          };
        }
        {
          key = "<esc>";
          action = "<cmd>noh<cr><esc>";
          options = {
            desc = "Escape and clear hlsearch";
          };
        }

        {
          key = "<leader>w";
          action = "<cmd>w<cr>";
          mode = "n";
          options.desc = "Save";
        }
        {
          key = "<leader>q";
          action = "<cmd>q<cr>";
          mode = "n";
          options.desc = "Quit";
        }

        {
          key = "gd";
          action = ''<cmd>lua require("definition-or-references").definition_or_references();<cr>'';
          mode = "n";
          options.desc = "Go to definition or references";
        }

        # leap (without hijacking visual-mode x)
        # {{"n", "x", "o"}, "s", "<Plug>(leap-forward-to)", "Leap forward to"},
        {
          key = "s";
          mode = [ "n" "x" "o" ];
          options.desc = "Leap forward to";
          action = "<Plug>(leap-forward-to)";
        }

        # {{"n", "x", "o"}, "S", "<Plug>(leap-backward-to)", "Leap backward to"},
        {
          key = "S";
          mode = [ "n" "x" "o" ];
          options.desc = "Leap backward to";
          action = "<Plug>(leap-backward-to)";
        }

        # buffers 
        {
          key = "<leader>x";
          action = "<cmd>BufferClose<cr>";
          mode = "n";
          options.desc = "Close buffer";
        }
        {
          key = "<leader>X";
          action = "<cmd>BufferCloseAllButCurrentOrPinned<cr>";
          mode = "n";
          options.desc = "Close buffers (except current and pinned)";
        }
        {
          key = "<leader>bx";
          action = "<cmd>BufferClose<cr>";
          mode = "n";
          options.desc = "Close buffer";
        }
        {
          key = "<leader>bX";
          action = "<cmd>BufferCloseAllButCurrentOrPinned<cr>";
          mode = "n";
          options.desc = "Close buffers (except current and pinned)";
        }
        { key = "<leader>bj"; action = "<cmd>BufferPick<cr>"; options.desc = "Pick buffer"; }
        { key = "<leader>bp"; action = "<cmd>BufferPin<cr>"; mode = "n"; options.desc = "Pin buffer"; }
        { key = "<Tab>"; action = "<cmd>bn<CR>"; mode = "n"; }
        { key = "<S-Tab>"; action = "<cmd>bp<CR>"; mode = "n"; }

        # lsp
        { key = "<leader>la"; action = "<cmd>Lspsaga code_action<cr>"; mode = "n"; options.desc = "Code Actions"; }
        { key = "<leader>ld"; action = "<cmd>Telescope lsp_definitions<cr>"; mode = "n"; options.desc = "Definitions"; }
        { key = "K"; action = "<cmd>Lspsaga hover_doc<cr>"; mode = "n"; options.desc = "Hover Docs"; }
        { key = "<leader>lr"; action = "<cmd>Lspsaga rename<cr>"; mode = "n"; options.desc = "Rename"; }
        { key = "<leader>lo"; action = "<cmd>Lspsaga outline<cr>"; mode = "n"; options.desc = "Outline"; }
        { key = "[e"; mode = "n"; action = "<cmd>Lspsaga diagnostic_jump_next<cr>"; }
        { key = "]e"; mode = "n"; action = "<cmd>Lspsaga diagnostic_jump_prev<cr>"; }
        { key = "[E"; mode = "n"; action = "<cmd>lua NextError()<cr>"; }
        { key = "]E"; mode = "n"; action = "<cmd>lua PrevError()<cr>"; }

        ## trouble
        { key = "<leader>lt"; action = "<cmd>TroubleToggle<cr>"; options.desc = "Toggle Trouble"; }
        {
          key = "<leader>n";
          action = ''<cmd>lua require("trouble").next({skip_groups = true, jump = true});<cr>'';
          options.desc = "Next trouble";
          mode = "n";
        }
        {
          key = "<leader>N";
          action = ''<cmd>lua require("trouble").previous({skip_groups = true, jump = true});<cr>'';
          options.desc = "Previous trouble";
          mode = "n";
        }
        {
          key = "gR";
          action = "<cmd>TroubleToggle lsp_references<cr>";
          options.desc = "references";
          mode = "n";
        }

        # toggleterm
        { key = "<leader>g"; action = "<cmd>lua Gitui_toggle()<CR>"; }
        { key = "<leader>th"; mode = "n"; action = ":ToggleTerm direction=horizontal<CR>"; }
        { key = "<leader>tv"; mode = "n"; action = ":ToggleTerm direction=vertical<CR>"; }
        { key = "<leader>tf"; mode = "n"; action = ":ToggleTerm direction=float<CR>"; }
        # toggle is \\

        # Move inside wrapped line
        { key = "j"; mode = "n"; action = "v:count == 0 ? 'gj' : 'j'"; options = { silent = true; expr = true; }; }
        { key = "k"; mode = "n"; action = "v:count == 0 ? 'gk' : 'k'"; options = { silent = true; expr = true; }; }

        { key = "<C-S-j>"; mode = "n"; action = "<cmd>m .+1<cr>=="; options.desc = "Move down"; }
        { key = "<C-S-k>"; mode = "n"; action = "<cmd>m .-2<cr>=="; options.desc = "Move up"; }
        { key = "<C-S-j>"; mode = "i"; action = "<esc><cmd>m .+1<cr>==gi"; options.desc = "Move down"; }
        { key = "<C-S-k>"; mode = "i"; action = "<esc><cmd>m .-2<cr>==gi"; options.desc = "Move up"; }
        { key = "<C-S-j>"; mode = "v"; action = ":m '>+1<cr>gv=gv"; options.desc = "Move down"; }
        { key = "<C-S-k>"; mode = "v"; action = ":m '<-2<cr>gv=gv"; options.desc = "Move up"; }

        # Telescope
        {
          key = "<leader>/";
          action = ''<cmd>Telescope current_buffer_fuzzy_find<CR>'';
          options.desc = "find in current buffer";
          mode = "n";
        }
        {
          key = "<leader>ff";
          mode = "n";
          action = ''<cmd>Telescope find_files<CR>'';
          options.desc = "find file";
        }
        {
          key = "<leader>fr";
          mode = "n";
          action = ''<cmd>Telescope resume<CR>'';
          options.desc = "resume previous";
        }
        {
          key = "<leader>fs";
          mode = "n";
          action = ''<cmd>Telescope live_grep<CR>'';
          options.desc = "find word";
        }
        {
          key = "<leader>fd";
          mode = "n";
          action = ''<cmd>Telescope lsp_workspace_symbols<CR>'';
          options.desc = "find symbol in workspace";
        }
        {
          key = "<leader>fD";
          mode = "n";
          action = ''<cmd>Telescope lsp_document_symbols<CR>'';
          options.desc = "find symbol in document";
        }
        {
          key = "<leader>fb";
          mode = "n";
          action = ''<cmd>Telescope buffers<CR>'';
          options.desc = "find buffer";
        }
        {
          key = "<leader>fh";
          mode = "n";
          action = ''<cmd>Telescope help_tags<CR>'';
          options.desc = "find help";
        }
        {
          key = "<leader>:";
          mode = "n";
          action = "<cmd>Telescope command_history<cr>";
          options.desc = "Command History";
        }
        {
          key = "<leader>fk";
          mode = "n";
          action = "<cmd>Telescope keymaps<cr>";
          options.desc = "Key Maps";
        }
        {
          key = "<leader>,";
          mode = "n";
          action = "<cmd>Telescope buffers<cr>";
          options.desc = "recent buffers";
        }

        {
          key = "<leader>.";
          mode = "n";
          action = "<cmd>@:<CR>";
          options.desc = "Repeat last command";
        }

        # rust-tools-nvim
        {
          key = "<leader>r";
          mode = "n";
          action = "<cmd>lua require('rust-tools').runnables.runnables()<CR>";
          options.desc = "Rust Runnables";
        }

        # keep selection when indenting
        { key = ">"; mode = "v"; action = ">gv"; }
        { key = "<"; mode = "v"; action = "<gv"; }

        {
          key = "<leader><CR>";
          mode = "n";
          action = "<cmd>lua vim.lsp.buf.format {async = true;}<CR>";
          options.desc = "Format buffer (via LSP)";
        }
        {
          key = "<leader><CR>";
          mode = "v";
          action = ''<cmd>lua FormatSelection()<CR>'';
          options.desc = "Format selection (via LSP)";
        }

        # splits
        {
          key = "<leader>sv";
          mode = "n";
          action = "<C-w>v";
          options.desc = "split vertically";
        }
        {
          key = "<leader>sh";
          mode = "n";
          action = "<C-w>s";
          options.desc = "split horizontally";
        }
        {
          key = "<leader>se";
          mode = "n";
          action = "<C-w>=";
          options.desc = "even splits";
        }
        {
          key = "<leader>sx";
          mode = "n";
          action = "<cmd>:close<CR>";
          options.desc = "close current window split";
        }

        { key = "<C-h>"; mode = "n"; action = "<cmd>wincmd h<CR>"; }
        { key = "<C-j>"; mode = "n"; action = "<cmd>wincmd j<CR>"; }
        { key = "<C-k>"; mode = "n"; action = "<cmd>wincmd k<CR>"; }
        { key = "<C-l>"; mode = "n"; action = "<cmd>wincmd l<CR>"; }

        # crates-nvim
        { key = "<leader>ct"; mode = "n"; action = ":lua require('crates').toggle()<cr>"; }
        { key = "<leader>cr"; mode = "n"; action = ":lua require('crates').reload()<cr>"; }

        { key = "<leader>cv"; mode = "n"; action = ":lua require('crates').show_versions_popup()<cr>"; }
        { key = "<leader>cf"; mode = "n"; action = ":lua require('crates').show_features_popup()<cr>"; }
        { key = "<leader>cd"; mode = "n"; action = ":lua require('crates').show_dependencies_popup()<cr>"; }

        { key = "<leader>cu"; mode = "n"; action = ":lua require('crates').update_crate()<cr>"; }
        { key = "<leader>cu"; mode = "v"; action = ":lua require('crates').update_crates()<cr>"; }
        { key = "<leader>ca"; mode = "n"; action = ":lua require('crates').update_all_crates()<cr>"; }
        { key = "<leader>cU"; mode = "n"; action = ":lua require('crates').upgrade_crate()<cr>"; }
        { key = "<leader>cU"; mode = "v"; action = ":lua require('crates').upgrade_crates()<cr>"; }
        { key = "<leader>cA"; mode = "n"; action = ":lua require('crates').upgrade_all_crates()<cr>"; }

        { key = "<leader>cH"; mode = "n"; action = ":lua require('crates').open_homepage()<cr>"; }
        { key = "<leader>cR"; mode = "n"; action = ":lua require('crates').open_repository()<cr>"; }
        { key = "<leader>cD"; mode = "n"; action = ":lua require('crates').open_documentation()<cr>"; }
        { key = "<leader>cC"; mode = "n"; action = ":lua require('crates').open_crates_io()<cr>"; }

        # nvim-test
        { key = "<leader>uu"; mode = "n"; action = "<cmd>TestLast<CR>"; }
        { key = "<leader>uf"; mode = "n"; action = "<cmd>TestFile<CR>"; }
        { key = "<leader>ur"; mode = "n"; action = "<cmd>TestNearest<CR>"; }
        { key = "<leader>ua"; mode = "n"; action = "<cmd>TestSuite<CR>"; }

        # LSP (todo, inspiration: https://youtu.be/vdn_pKJUda8?t=3129)
      ];
      extraPlugins = with pkgs.vimPlugins; [
        {
          plugin = (fromGitHub "KostkaBrukowa/definition-or-references.nvim" "0.0" "6e9f3b5a7e460094c7e0916b7f1fa69f4043061f");
          config = mkLua ''require("definition-or-references").setup()'';
        }
        friendly-snippets
        {
          plugin = (fromGitHub "chrishrb/gx.nvim" "0.2.0" "a7cb094499907b3561aa6e135240dccbd89ed8a8");
          config = mkLua ''require("gx").setup()'';
        }
        kmonad-vim
        {
          plugin = luasnip;
          config = mkLua ''require("luasnip/loaders/from_vscode").lazy_load()'';
        }
        {
          plugin = (fromGitHub "klen/nvim-test" "1.3.0" "4e30d0772a43bd67ff299cfe201964c5bd799d73");
          config = mkLuaFile ./vim/plugins/nvim-test.lua;
        }
        {
          plugin = noice-nvim;
          config = mkLuaFile ./vim/plugins/noice.lua;
        }
        plenary-nvim
        {
          plugin = rest-nvim;
          config = mkLuaFile ./vim/plugins/nvim-rest.lua;
        }
        (fromGitHub "ibhagwan/smartyank.nvim" "feb25" "7e3905578f646503525b2f7018b8afd17861018c")
        {
          plugin = tint-nvim;
          config = mkLua ''require("tint").setup()'';
        }
        {
          plugin = toggleterm-nvim;
          config = mkLuaFile ./vim/plugins/toggleterm.lua;
        }
      ];
      extraConfigLua = builtins.readFile ./vim/init.lua;
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

