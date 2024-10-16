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
    theme = mkOption {
      type = enum [ "ayu" "everforest" "catppuccin" "rose-pine" "tokyonight" "vscode" ];
      default = "rose-pine";
      description = "theme for tmux";
    };
    auto-dark-mode = mkOption {
      type = bool;
      default = pkgs.stdenv.isDarwin;
      description = "auto darkmode";
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
    lsp.servers.python = mkOption {
      type = types.bool;
      default = false;
      description = "python lsp enabled";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      lazygit
      nixpkgs-fmt
      ripgrep
      taplo # toml formatter
    ];

    home.file = mkIf cfg.ideavim {
      ".ideavimrc".source = ./vim/ideavimrc;
    };

    programs.nixvim = {
      enable = true;
      globals.mapleader = " ";
      opts = {
        autoindent = true;
        autowriteall = true;
        backspace = "indent,eol,start";
        breakindent = true;
        clipboard = "unnamedplus";
        colorcolumn = "100";
        cursorline = true;

        foldcolumn = "1";
        foldenable = true;
        foldlevel = 99;
        foldlevelstart = 99;
        foldmethod = "manual";

        ignorecase = true;
        inccommand = "split";
        number = true;
        relativenumber = true;
        scrolloff = 49;
        sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions";
        shiftwidth = 4;
        signcolumn = "yes";
        smartcase = true;
        swapfile = false;
        tabstop = 4;
        undofile = true;
        writebackup = false;
      };

      autoCmd = [
        # Open help in a vertical split
        {
          event = "FileType";
          pattern = "help";
          command = "wincmd L";
        }

        # Close Telescope prompt in insert mode by clicking escape
        {
          event = [ "FileType" ];
          pattern = "TelescopePrompt";
          command = "inoremap <buffer><silent> <ESC> <ESC>:close!<CR>";
        }

        # Enable spellcheck for some filetypes
        {
          event = "FileType";
          pattern = [
            "tex"
            "latex"
            "markdown"
          ];
          command = "setlocal spell spelllang=en";
        }
        # Hilight yank text
        {
          event = "TextYankPost";
          pattern = "*";
          command = "lua vim.highlight.on_yank{timeout=500}";
        }

      ];

      colorschemes."${cfg.theme}" = { enable = true; };
      diagnostics.virtual_lines.only_current_line = true;
      luaLoader.enable = true;
      plugins = {
        barbar = { enable = true; settings.animation = false; };
        cmp = {
          enable = true;
          settings.mapping = {
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<C-CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-p>" = "cmp.mapping.select_prev_item { behavior == cmp.SelectBehavior.Insert }";
            "<C-n>" = "cmp.mapping.select_next_item { behavior == cmp.SelectBehavior.Insert }";

            "<CR>" = ''cmp.mapping({
               i = function(fallback)
                 if cmp.visible() and cmp.get_active_entry() then
                   cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                 else
                   fallback()
                 end
               end,
               s = cmp.mapping.confirm({ select = true }),
               c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
             })'';

            "<Tab>" = ''cmp.mapping(function(fallback)
                  local luasnip = require("luasnip")
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                  else
                    fallback()
                  end
                end, { "i", "s" })'';

            "<S-Tab>" = ''cmp.mapping(function(fallback)
                local luasnip = require("luasnip")
                if cmp.visible() then
                cmp.select_prev_item()
                elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
                else
                fallback()
                end
                end, { "i", "s" })'';
          };

          settings.snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          settings.sources = [
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "luasnip"; }
            { name = "treesitter"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "crates"; }
          ] ++ (if cfg.copilot.enable then [{ name = "copilot"; }] else [ ]);
        };
        conform-nvim = {
          enable = true;
          settings.format_on_save = {
            lspFallback = true;
            timeoutMs = 1000;
          };
          settings.formatters_by_ft = {
            toml = [ "taplo" ];
            python = [ "isort" "black" ];
          };
        };
        comment = { enable = true; };
        copilot-lua = {
          enable = cfg.copilot.enable;
          suggestion.enabled = false;
          panel.enabled = false;
        };
        copilot-cmp = {
          enable = cfg.copilot.enable;
          fixPairs = false;
        };
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
        flash = {
          enable = true;
          settings.modes.search.enabled = true;
        };
        gitblame = {
          enable = true;
          settings.enabled = false; # toggle with H
        };
        gitsigns = {
          enable = true;
          settings.on_attach = ''
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
        inc-rename = { enable = true; showMessage = true; };
        indent-blankline = {
          enable = true;
          settings.scope = {
            enabled = true;
            show_start = true;
          };
          # settings.whitespace.remove_blankline_trail = false;
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
            nil-ls = {
              enable = true;
              settings.formatting.command = [ "nixpkgs-fmt" ];
              settings.nix.flake.autoArchive = true;
            };
            basedpyright.enable = cfg.lsp.servers.python;
            ts-ls.enable = cfg.lsp.servers.javascript;
          };
        };
        lsp-lines = {
          enable = true;
        };
        lsp-format = {
          enable = true;
        };
        lspkind = {
          enable = true;
          cmp.enable = true;
          symbolMap = {
            Class = "ﴯ";
            Color = "";
            Constant = "";
            Constructor = "";
            Copilot = "";
            Enum = "";
            EnumMember = "";
            Event = "";
            Field = "ﰠ";
            File = "";
            Folder = "";
            Function = "";
            Interface = "";
            Keyword = "";
            Method = "";
            Module = "";
            Operator = "";
            Property = "ﰠ";
            Reference = "";
            Snippet = "﬌";
            Struct = "פּ";
            Text = "";
            TypeParameter = "";
            Unit = "塞";
            Value = "";
            Variable = "";
          };
        };
        lspsaga = {
          enable = true;
          lightbulb.virtualText = false;
        };
        lualine = {
          enable = true;
          settings.options = {
            section_separators = { left = ""; right = ""; };
            component_separators = { left = ""; right = ""; };
          };
        };
        markdown-preview.enable = true;
        mini = {
          enable = true;
          modules = {
            cursorword = { };
            indentscope = { };
            starter = {
              header =
                ''
                                                                
                        ███████████            █████      ██
                       ███████████              █████ 
                       ████████████████ ███ ████████ ███   ███████
                      ████████████████ ████ ████████ █████ ██████████████
                     ██████████████████████ ███████ █████ █████ ████ █████
                   ████████████████████████████ ██████ █████ █████ ████ █████
                  ██████  ███ █████████████████  ████ █████ █████ ████ ██████
                  ██████   ██  ███████████████    ██ █████████████████
                '';

            };
            sessions = { autoread = false; autowrite = false; file = ""; directory.__raw = "vim.fn.stdpath('state')..'/sessions/'"; };
            surround = { };
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
        nvim-ufo = {
          enable = true;
          closeFoldKinds = {
            default = [ "imports" "comment" ];
            json = [ "array" ];
            c = [ "comment" "region" ];
          };
          providerSelector = ''
            function(bufnr, filetype, buftype)
              local ftMap = {
                 vim = 'indent',
                 python = {'indent'},
                 nix = {'treesitter', 'indent'},
                 git = ""
              }
              return ftMap[filetype] or {'lsp', 'indent'}
            end
          '';
        };
        oil = {
          enable = true;
          settings = {
            keymaps = {
              "C-h" = false;
            };
            skip_confirm_for_simple_edits = true;
            delete_to_trash = true;
            view_options = {
              show_hidden = true;
              is_always_hidden.__raw = ''
                function(name, _)
                  return name == '..' or name == '.git'
                end
              '';
            };
          };
        };
        persistence = {
          enable = true;
        };
        rustaceanvim = mkMerge [
          {
            enable = true;
            settings =
              {
                # https://github.com/MysticalDevil/inlay-hints.nvim?tab=readme-ov-file#rust-analyzer
                default_settings.rust-analyzer.inlayHints = {
                  bindingModeHints = {
                    enable = false;
                  };
                  chainingHints = {
                    enable = true;
                  };
                  closingBraceHints = {
                    enable = true;
                    minLines = 25;
                  };
                  closureReturnTypeHints = {
                    enable = "never";
                  };
                  lifetimeElisionHints = {
                    enable = "never";
                    useParameterNames = false;
                  };
                  maxLength = 25;
                  parameterHints = {
                    enable = true;
                  };
                  reborrowHints = {
                    enable = "never";
                  };
                  renderColons = true;
                  typeHints = {
                    enable = true;
                    hideClosureInitialization = false;
                    hideNamedConstructor = false;
                  };
                };
              };
          }
          (if cfg.codelldb.enable then {
            settings.dap.adapter = {
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
            settings.dap.adapter.command = "lldb";
            settings.dap.adapter.type = "executable";
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
          extensions.frecency.enable = true;
        };
        treesitter = {
          enable = true;
          nixGrammars = true;
          package = cfg.treesitter.package;
          grammarPackages = treesitterGrammars cfg.treesitter.grammarPackageSet cfg.treesitter.package;
          settings.incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<Leader>v";
              node_incremental = "<Leader>v";
              scope_incremental = false;
              node_decremental = "<BS>";
            };
          };
        };
        tmux-navigator.enable = true;
        treesitter-context = {
          enable = true;
          settings = {
            max_lines = 4;
          };
        };
        treesitter-textobjects = {
          enable = true;
          move = {
            enable = true;
            setJumps = true;
            gotoNextStart = {
              "]f" = { query = "@function.outer"; desc = "Next function start"; };
              "]c" = { query = "@class.outer"; desc = "Next class/struct start"; };
            };
            gotoNextEnd = {
              "]F" = { query = "@function.outer"; desc = "Next function end"; };
              "]C" = { query = "@class.outer"; desc = "Next class/struct end"; };
            };
            gotoPreviousStart = {
              "[f" = { query = "@function.outer"; desc = "Previous function start"; };
              "[c" = { query = "@class.outer"; desc = "Previous class/struct start"; };
            };
            gotoPreviousEnd = {
              "[F" = { query = "@function.outer"; desc = "Previous function end"; };
              "[C" = { query = "@class.outer"; desc = "Previous class/struct end"; };
            };
          };
        };
        trouble = { enable = true; };
        web-devicons.enable = true;
        which-key = {
          enable = true;
          settings.win.border = "single";
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
          action = "<cmd>noh<cr><cmd>Noice dismiss<cr><esc>";
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

        # buffers
        {
          key = "<leader>x";
          action = "<cmd>BufferClose<cr>";
          mode = "n";
          options.desc = "Close buffer";
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
        { key = "<leader>bp"; action = "<cmd>BufferPin<cr>"; mode = "n"; options.desc = "Pin buffer"; }
        { key = "<Tab>"; action = "<cmd>bn<CR>"; mode = "n"; }
        { key = "<S-Tab>"; action = "<cmd>bp<CR>"; mode = "n"; }

        # lsp
        { key = "<leader>la"; action = "<cmd>Lspsaga code_action<cr>"; mode = "n"; options.desc = "Code Actions"; }
        { key = "<leader>a"; action = "<cmd>Lspsaga code_action<cr>"; mode = "n"; options.desc = "Code Actions"; }
        { key = "<leader>ld"; action = "<cmd>Telescope lsp_definitions<cr>"; mode = "n"; options.desc = "Definitions"; }
        { key = "K"; action = "<cmd>Lspsaga hover_doc<cr>"; mode = "n"; options.desc = "Hover Docs"; }
        {
          key = "H";
          action = "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR><cmd>GitBlameToggle<CR>";
          mode = "n";
          options.desc = "Toggle inlay Hints & gitblame Toggle";
        }
        {
          key = "<leader>lh";
          action.__raw = ''
            function()
              vim.diagnostic.enable(not vim.diagnostic.is_enabled())
              vim.print("diagnostics " .. (vim.diagnostic.is_enabled() and "enabled" or "disabled"))
            end'';
          mode = "n";
          options.desc = "Toggle vim diagnostics";
        }
        { key = "<leader>lR"; action = ":IncRename "; mode = "n"; options.desc = "Rename"; } # another in init.lua
        { key = "<leader>lo"; action = "<cmd>Lspsaga outline<cr>"; mode = "n"; options.desc = "Outline"; }

        # square bracket motions
        { key = "]d"; mode = "n"; action = ''<cmd>lua diagnostic_goto(true)<cr>''; options.desc = "Next Diagnostic"; }
        { key = "[d"; mode = "n"; action = ''<cmd>lua diagnostic_goto(false)<cr>''; options.desc = "Prev Diagnostic"; }

        { key = "]e"; mode = "n"; action = ''<cmd>lua diagnostic_goto(true, "ERROR")<cr>''; options.desc = "Next Error"; }
        { key = "[e"; mode = "n"; action = ''<cmd>lua diagnostic_goto(false, "ERROR")<cr>''; options.desc = "Prev Error"; }

        { key = "]w"; mode = "n"; action = ''<cmd>lua diagnostic_goto(true, "WARNING")<cr>''; options.desc = "Next Warning"; }
        { key = "[w"; mode = "n"; action = ''<cmd>lua diagnostic_goto(false, "WARNING")<cr>''; options.desc = "Prev Warning"; }

        { key = "]]"; mode = "n"; action = ''<cmd>lua illuminate_goto_reference("next")<cr>''; options.desc = "Next reference"; }
        { key = "[["; mode = "n"; action = ''<cmd>lua illuminate_goto_reference("prev")<cr>''; options.desc = "Prev reference"; }

        { key = "]q"; mode = "n"; action = ''<cmd>cnext<cr>''; options.desc = "Next quickfix"; }
        { key = "[q"; mode = "n"; action = ''<cmd>cprev<cr>''; options.desc = "Prev quickfix"; }

        # oil
        { key = "-"; mode = "n"; action = ''<cmd>Oil --float<cr>''; options.desc = "Open parent dir (float)"; }

        # copying current files path
        {
          key = "<leader>yp";
          action.__raw = ''
            function()
              vim.fn.setreg('+', vim.fn.expand('%:p:.'))
            end'';
          options.desc = "Copy file path (relative to project)";
        }
        {
          key = "<leader>ya";
          action.__raw = ''
            function()
              vim.fn.setreg('+', vim.fn.expand('%:p'))
            end'';
          options.desc = "Copy file path (absolute)";
        }
        {
          key = "<leader>yd";
          action.__raw = ''
            function()
              vim.fn.setreg('+', vim.fn.expand('%:h'))
            end'';
          options.desc = "Copy directory path";
        }
        {
          key = "<leader>yf";
          action.__raw = ''
            function()
              vim.fn.setreg('+', vim.fn.expand('%:p:t'))
            end'';
          options.desc = "Copy file name";
        }

        ## trouble
        {
          key = "<leader>tq";
          action = "<cmd>Trouble quickfix toggle focus=true<cr>";
          options.desc = "Trouble Quickfix";
        }
        { key = "<leader>tt"; action = "<cmd>Trouble telescope toggle focus=true<cr>"; options.desc = "Trouble Telescope"; }
        { key = "<leader>tf"; action = "<cmd>Trouble telescope_files toggle focus=true<cr>"; options.desc = "Trouble Telescope files"; }
        { key = "<leader>td"; action = "<cmd>Trouble diagnostics toggle focus=true<cr>"; options.desc = "Trouble Diagnostics"; }
        { key = "<leader>ts"; action = "<cmd>Trouble symbols toggle focus=true<cr>"; options.desc = "Trouble Symbols"; }
        {
          key = "<F7>";
          action = ''<cmd>lua require("trouble").next({skip_groups = true, jump = true});<cr>'';
          options.desc = "Next trouble";
          mode = "n";
        }
        {
          key = "<F8>";
          action = ''<cmd>lua require("trouble").prev({skip_groups = true, jump = true});<cr>'';
          options.desc = "Previous trouble";
          mode = "n";
        }
        {
          key = "<leader>n";
          action = ''<cmd>lua require("trouble").next({skip_groups = true, jump = true});<cr>'';
          options.desc = "Next trouble";
          mode = "n";
        }
        {
          key = "<leader>N";
          action = ''<cmd>lua require("trouble").prev({skip_groups = true, jump = true});<cr>'';
          options.desc = "Previous trouble";
          mode = "n";
        }
        {
          key = "gr";
          action = "<cmd>Trouble lsp_references toggle focus=true<cr>";
          options.desc = "Trouble references";
          mode = "n";
        }

        # toggleterm
        { key = "<leader>g"; action = "<cmd>lua Gitui_toggle()<CR>"; }
        # { key = "<leader>th"; mode = "n"; action = ":ToggleTerm direction=horizontal<CR>"; }
        # { key = "<leader>tv"; mode = "n"; action = ":ToggleTerm direction=vertical<CR>"; }
        # { key = "<leader>tf"; mode = "n"; action = ":ToggleTerm direction=float<CR>"; }
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
          key = "<leader>fF";
          mode = "n";
          action = "<cmd>lua require('telescope.builtin').find_files({no_ignore = true, hidden = true})<cr>";
          options.desc = "find file (including ignored, hidden)";
        }
        {
          key = "<leader>fg";
          mode = "n";
          action = ''<cmd>Telescope git_bcommits<CR>'';
          options.desc = "git commits for current buffer";
        }
        {
          key = "<leader>fg";
          mode = "v";
          action = ''<cmd>Telescope git_bcommits_range<CR>'';
          options.desc = "git commits for current buffer with selected range";
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
          key = "<leader>fp";
          mode = "n";
          action = ''<cmd>Telescope session-lens<CR>'';
          options.desc = "find session (project)";
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
          key = "<leader>fe";
          mode = "n";
          action = ''<cmd>Telescope diagnostics<CR>'';
          options.desc = "diagnostics in project";
        }
        {
          key = "<leader>fE";
          mode = "n";
          action = ''<cmd>Telescope diagnostics bufnr=0<CR>'';
          options.desc = "diagnostics in current buffer";
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
          key = "<leader><CR>"; # todo: conflict with flash treesitter
          mode = "n";
          action = ''<cmd>lua FormatBuffer()<CR>'';
          options.desc = "Format buffer (via conform/LSP)";
        }
        {
          key = "<leader><CR>";
          mode = "v";
          action = ''<cmd>lua FormatSelection()<CR>'';
          options.desc = "Format selection (via conform/LSP)";
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
        # flash
        {
          key = "<CR>";
          mode = [ "n" "x" "o" ];
          action = ''<cmd>lua require("flash").jump()<CR>'';
          options.desc = "flash search";
        }
        {
          key = "<leader><CR>";
          mode = [ "n" "x" "o" ];
          action = ''<cmd>lua require("flash").treesitter()<CR>'';
          options.desc = "flash treesitter";
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

        # ufo / fold peek
        {
          key = "zK";
          mode = "n";
          action.__raw = ''
            function()
              local winid = require('ufo').peekFoldedLinesUnderCursor()
              if not winid then
                vim.lsp.buf.hover()
              end
            end
          '';
          options.desc = "peek fold";
        }
      ];
      extraPlugins = with pkgs.vimPlugins; [
        (if cfg.auto-dark-mode then
          {
            plugin = (fromGitHub "f-person/auto-dark-mode.nvim" "2024-07-29" "14cad96b80a07e9e92a0dcbe235092ed14113fb2");
            config = mkLuaFile ./vim/plugins/auto-dark-mode.lua;
          }
        else
          {
            plugin = (fromGitHub "eliseshaffer/darklight.nvim" "0.6" "d6ab8f3b2921dcdc4591961f89c34b467387f2eb");
            config = mkLua ''require('darklight').setup()'';
          })
        {
          plugin = (fromGitHub "KostkaBrukowa/definition-or-references.nvim" "2023.10.7" "13570f995be8993f4c55e988f89e5a7b8df37a17");
          config = mkLuaFile ./vim/plugins/definition-or-references.lua;
        }
        {
          plugin = nvim-FeMaco-lua;
          config = mkLuaFile ./vim/plugins/femaco.lua;
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
        {
          plugin = markview-nvim;
          config = mkLuaFile ./vim/plugins/markview.lua;
        }
        plenary-nvim
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
      extraConfigLua =
        (builtins.readFile ./vim/init.lua) +
        (builtins.readFile ./vim/plugins/persistence.lua);
    };
    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nv = "nvim";
    };
  };
}


