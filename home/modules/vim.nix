{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.vim;

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
    codelldb.enable = mkEnableOption "lldb";
    copilot.enable = mkOption { type = bool; default = true; description = "copilot"; };
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
      nixpkgs-fmt
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
        cmp = {
          enable = true;
          settings.mapping = {
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
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<Up>" = "cmp.mapping.select_prev_item()";
            "<Down>" = "cmp.mapping.select_next_item()";
            "<C-Space>" = "cmp.mapping.complete()";
          };

          settings.snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          settings.sources = [
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "luasnip"; }
            { name = "treesitter"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "crates"; }
          ] ++ (if cfg.copilot.enable then [{ name = "copilot"; }] else [ ]);
        };
        copilot-lua = {
          enable = cfg.copilot.enable;
          suggestion.enabled = false;
          panel.enabled = false;
        };
        copilot-cmp.enable = cfg.copilot.enable;
        copilot-chat = {
          enable = cfg.copilot.enable;
          settings = {
            mappings = {
              accept_diff = {
                insert = "<C-y>";
                normal = "<C-y>";
              };
              close = {
                insert = "<C-c>";
                normal = "q";
              };
              complete = {
                detail = "Use @<Tab> or /<Tab> for options.";
                insert = "<Tab>";
              };
              reset = {
                insert = "<C-R>";
                normal = "<C-R>";
              };
              show_diff = {
                normal = "gd";
              };
              show_system_prompt = {
                normal = "gp";
              };
              show_user_selection = {
                normal = "gs";
              };
              submit_prompt = {
                insert = "<C-m>";
                normal = "<CR>";
              };
              yank_diff = {
                normal = "gy";
              };
            };
          };
        };
        crates-nvim = { enable = true; };
        dap = {
          enable = true;
          extensions = {
            dap-ui.enable = true;
            dap-virtual-text.enable = true;
          };
        };
        efmls-configs = {
          enable = true;
          setup = {
            bash.linter = "shellcheck";
          };
        };
        gitblame.enable = true;
        gitsigns = {
          enable = true;
          onAttach.function = ''
            function(buffer)
              local gs = package.loaded.gitsigns
              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
              end
              map("n", "]g", gs.next_hunk, "Next Hunk")
              map("n", "[g", gs.prev_hunk, "Prev Hunk")
            end'';
        };
        harpoon = {
          enable = true;
          keymaps = {
            addFile = "<leader>ja";
            toggleQuickMenu = "<leader>jj";
            navFile = {
              "1" = "<M-f>";
              "2" = "<M-d>";
              "3" = "<M-s>";
              "4" = "<M-a>";
            };
            navNext = "<C-]>";
            navPrev = "<C-[>";
          };
        };
        illuminate = { enable = true; };
        inc-rename = { enable = true; };
        indent-blankline = {
          enable = true;
          scope = {
            enabled = true;
            showStart = true;
          };
          whitespace.removeBlanklineTrail = false;
        };
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
            marksman.enable = true;
            omnisharp = {
              enable = cfg.lsp.servers.omnisharp;
              settings = {
                enableImportCompletion = true;
                enableRoslynAnalyzers = true;
              };
            };
            nil_ls = {
              enable = true;
              settings.formatting.command = [ "nixpkgs-fmt" ];
            };
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
        markdown-preview.enable = true;
        mini = {
          enable = true;
          modules = {
            indentscope = { };
            trailspace = { };
          };
        };
        neo-tree = {
          enable = true;
          closeIfLastWindow = true;
          autoCleanAfterSessionRestore = true;
          openFilesInLastWindow = true;
          filesystem.followCurrentFile.enabled = true;
          sourceSelector.winbar = true;
          eventHandlers = {
            file_opened = ''
              function(file_path)
                require("neo-tree").close_all()
              end
            '';
          };
        };
        nix.enable = true;
        notify.enable = true;
        nvim-autopairs.enable = true;
        project-nvim.enable = true;
        rustaceanvim = mkMerge [
          { enable = true; }
          (if cfg.codelldb.enable then {
            dap.adapter = {
              executable.command = "${pkgs.code-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
              executable.args = [
                "--liblldb"
                "${pkgs.code-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.dylib"
                "--port"
                "1337"
              ];
              type = "server";
              port = "1337";
              host = "127.0.0.1";
            };
          } else {
            dap.adapter.command = "lldb";
            dap.adapter.type = "executable";
          })
        ];
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
          action = "<cmd>Neotree toggle<CR>";
          options = {
            silent = true;
            desc = "neotree toggle";
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
        { key = "<leader>lr"; action = ":IncRename "; mode = "n"; options.desc = "Rename"; }
        { key = "<leader>lo"; action = "<cmd>Lspsaga outline<cr>"; mode = "n"; options.desc = "Outline"; }

        # square bracket motions
        { key = "]d"; mode = "n"; action = ''<cmd>lua diagnostic_goto(true)<cr>''; options.desc = "Next Diagnostic"; }
        { key = "[d"; mode = "n"; action = ''<cmd>lua diagnostic_goto(false)<cr>''; options.desc = "Prev Diagnostic"; }

        { key = "]e"; mode = "n"; action = ''<cmd>lua diagnostic_goto(true, "ERROR")<cr>''; options.desc = "Next Error"; }
        { key = "[e"; mode = "n"; action = ''<cmd>lua diagnostic_goto(false, "ERROR")<cr>''; options.desc = "Prev Error"; }

        { key = "]w"; mode = "n"; action = ''<cmd>lua diagnostic_goto(true, "WARNING")<cr>''; options.desc = "Next Warning"; }
        { key = "[w"; mode = "n"; action = ''<cmd>lua diagnostic_goto(false, "WARNING")<cr>''; options.desc = "Prev Warning"; }

        { key = "]]"; mode = "n"; action = ''<cmd>lua illuminate_goto_reference("next")<cr>''; options.desc = "Goto next reference"; }
        { key = "[["; mode = "n"; action = ''<cmd>lua illuminate_goto_reference("prev")<cr>''; options.desc = "Goto prev reference"; }

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
          action = "<cmd>lua require('telescope.builtin').buffers({sort_mru=true, ignore_current_buffer=true})<cr>";
          options.desc = "recent buffers";
        }

        {
          key = "<leader>.";
          mode = "n";
          action = "<cmd>@:<CR>";
          options.desc = "Repeat last command";
        }

        # rustaceanvim
        {
          key = "<leader>rr";
          mode = "n";
          action = "<cmd>RustLsp runnables<CR>";
          options.desc = "Rust Runnables";
        }
        {
          key = "<leader>rd";
          mode = "n";
          action = "<cmd>RustLsp debuggables<CR>";
          options.desc = "Rust Debuggables";
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
        { key = "<leader>rct"; mode = "n"; action = ":lua require('crates').toggle()<cr>"; }
        { key = "<leader>rcr"; mode = "n"; action = ":lua require('crates').reload()<cr>"; }

        { key = "<leader>rcv"; mode = "n"; action = ":lua require('crates').show_versions_popup()<cr>"; }
        { key = "<leader>rcf"; mode = "n"; action = ":lua require('crates').show_features_popup()<cr>"; }
        { key = "<leader>rcd"; mode = "n"; action = ":lua require('crates').show_dependencies_popup()<cr>"; }

        { key = "<leader>rcu"; mode = "n"; action = ":lua require('crates').update_crate()<cr>"; }
        { key = "<leader>rcu"; mode = "v"; action = ":lua require('crates').update_crates()<cr>"; }
        { key = "<leader>rca"; mode = "n"; action = ":lua require('crates').update_all_crates()<cr>"; }
        { key = "<leader>rcU"; mode = "n"; action = ":lua require('crates').upgrade_crate()<cr>"; }
        { key = "<leader>rcU"; mode = "v"; action = ":lua require('crates').upgrade_crates()<cr>"; }
        { key = "<leader>rcA"; mode = "n"; action = ":lua require('crates').upgrade_all_crates()<cr>"; }

        { key = "<leader>rcH"; mode = "n"; action = ":lua require('crates').open_homepage()<cr>"; }
        { key = "<leader>rcR"; mode = "n"; action = ":lua require('crates').open_repository()<cr>"; }
        { key = "<leader>rcD"; mode = "n"; action = ":lua require('crates').open_documentation()<cr>"; }
        { key = "<leader>rcC"; mode = "n"; action = ":lua require('crates').open_crates_io()<cr>"; }

        # copilot-chat
        { key = "<leader>cc"; mode = "n"; action = ":CopilotChatToggle<cr>"; options.desc = "Copilot chat toggle"; }
        { key = "<leader>ce"; mode = "n"; action = ":CopilotChatExplain<cr>"; options.desc = "Copilot explain selection"; }
        { key = "<leader>cr"; mode = "v"; action = ":CopilotChatReview<cr>"; options.desc = "Copilot review"; }
        { key = "<leader>cd"; mode = "v"; action = ":CopilotChatDocs<cr>"; options.desc = "Copilot generate docs"; }
        { key = "<leader>ct"; mode = "n"; action = ":CopilotChatTests<cr>"; options.desc = "Copilot generate tests"; }
        { key = "<leader>cfd"; mode = "n"; action = ":CopilotChatFixDiagnostic<cr>"; options.desc = "Copilot fix diagnostic"; }

        # nvim-test
        { key = "<leader>uu"; mode = "n"; action = "<cmd>TestLast<CR>"; }
        { key = "<leader>uf"; mode = "n"; action = "<cmd>TestFile<CR>"; }
        { key = "<leader>ur"; mode = "n"; action = "<cmd>TestNearest<CR>"; }
        { key = "<leader>ua"; mode = "n"; action = "<cmd>TestSuite<CR>"; }

        # LSP (todo, inspiration: https://youtu.be/vdn_pKJUda8?t=3129)
      ];
      extraPlugins = with pkgs.vimPlugins; [
        {
          plugin = (fromGitHub "KostkaBrukowa/definition-or-references.nvim" "0.0" "13570f995be8993f4c55e988f89e5a7b8df37a17");
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
        # {
        #   plugin = rest-nvim;
        #   config = mkLuaFile ./vim/plugins/nvim-rest.lua;
        # }
        (fromGitHub "ibhagwan/smartyank.nvim" "2024mar26" "d9e078fe08d6466e37ea45ac446a9f60e6866789")
        {
          plugin = tint-nvim;
          config = mkLua ''require("tint").setup()'';
        }
        {
          plugin = toggleterm-nvim;
          config = mkLuaFile ./vim/plugins/toggleterm.lua;
        }
        {
          plugin = vim-rsi;
          config = mkLua '''';
        }
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


