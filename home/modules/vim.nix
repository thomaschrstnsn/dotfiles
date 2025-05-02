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
    completionPlugin = mkOption {
      type = enum [ "cmp" "blink" ];
      default = "blink";
      description = "completion plugin (cmp or blink)";
    };
    theme = mkOption {
      type = enum [ "ayu" "everforest" "catppuccin" "rose-pine" "tokyonight" "vscode" ];
      default = "rose-pine";
      description = "theme for neovim";
    };
    auto-dark-mode = mkOption {
      type = bool;
      default = pkgs.stdenv.isDarwin;
      description = "auto darkmode";
    };
    splitNavigator = mkOption
      {
        type = enum [ "tmux-navigator" "smart-splits" ];
        default = "tmux-navigator";
        description = "split navigator plugin";
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
    markdown-preview.enable = mkEnableOption "markdown preview" // { default = true; };
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
    lsp.servers.roslyn = mkEnableOption "roslyn ls";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      lazygit
      nixpkgs-fmt
      ripgrep
      taplo # toml formatter
    ] ++ (if cfg.lsp.servers.roslyn then [ roslyn-ls ] else [ ]);

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
      diagnostic.settings.virtual_lines.only_current_line = true;
      luaLoader.enable = true;
      performance.byteCompileLua = {
        enable = true;
      };
      plugins = {
        barbar = { enable = true; settings.animation = false; };
        blink-cmp = {
          enable = cfg.completionPlugin == "blink";
          settings = {
            completion = {
              ghost_text.enabled = true;
              documentation.auto_show = true;
            };
            keymap = {
              preset = "super-tab";
            };
            signature = {
              enabled = true;
            };
            sources = {
              providers = {
                copilot = {
                  async = true;
                  module = "blink-cmp-copilot";
                  name = "copilot";
                  score_offset = 100;
                };
              };
              default = [
                "lsp"
                "path"
                "snippets"
                "buffer"
                (mkIf (cfg.copilot.enable) "copilot")
              ];
            };
          };
        };
        blink-cmp-copilot.enable = cfg.copilot.enable && cfg.completionPlugin == "blink";
        cmp = {
          enable = cfg.completionPlugin == "cmp";
          settings.mapping = {
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
            "<C-p>" = "cmp.mapping.select_prev_item { behavior == cmp.SelectBehavior.Insert }";
            "<Up>" = "cmp.mapping.select_prev_item { behavior == cmp.SelectBehavior.Insert }";
            "<C-n>" = "cmp.mapping.select_next_item { behavior == cmp.SelectBehavior.Insert }";
            "<Down>" = "cmp.mapping.select_next_item { behavior == cmp.SelectBehavior.Insert }";

            "<CR>".__raw = ''cmp.mapping({
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

            "<Tab>".__raw = ''cmp.mapping(function(fallback)
                  local luasnip = require("luasnip")
                  if cmp.visible() then
                    cmp.confirm({ select = true })
                  elseif luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                  else
                    fallback()
                  end
                end, { "i", "s" })'';

            "<S-Tab>".__raw = ''cmp.mapping(function(fallback)
                  local luasnip = require("luasnip")
                  if luasnip.locally_jumpable(-1) then
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
          settings = {
            suggestion.enabled = false;
            panel.enabled = false;
          };
        };
        copilot-cmp = {
          enable = cfg.copilot.enable && cfg.completionPlugin == "cmp";
          settings = {
            fix_pairs = false;
          };
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
        crates = { enable = true; };
        dap = {
          enable = true;
          extensions = { };
        };
        dap-ui.enable = true;
        dap-virtual-text.enable = true;
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
          settings.on_attach.__raw = ''
            function(buffer)
              local gs = package.loaded.gitsigns
              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
              end
              map("n", "]g", gs.next_hunk, "Next Hunk")
              map("n", "[g", gs.prev_hunk, "Prev Hunk")
            end'';
        };
        harpoon = { enable = true; };
        illuminate = { enable = true; };
        inc-rename = {
          enable = true;
          settings = { show_message = true; };
        };
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
            csharp_ls.enable = cfg.lsp.servers.csharp;
            eslint.enable = cfg.lsp.servers.javascript;
            jsonls.enable = cfg.lsp.servers.javascript;
            lua_ls.enable = true;
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
              settings.nix.flake.autoArchive = true;
            };
            basedpyright.enable = cfg.lsp.servers.python;
            ruff.enable = cfg.lsp.servers.python;
            ts_ls.enable = cfg.lsp.servers.javascript;
          };
        };
        lsp-lines = {
          enable = true;
        };
        lsp-format = {
          enable = true;
        };
        lspkind = {
          enable = cfg.completionPlugin == "cmp";
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
        markdown-preview.enable = cfg.markdown-preview.enable;
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
        nix.enable = true;
        noice = {
          enable = true;
          settings.notify.enabled = false;
          settings.lsp.signature.enabled = cfg.completionPlugin == "cmp";
        };
        nvim-autopairs.enable = true;
        nvim-ufo = {
          enable = true;
          settings = {
            close_fold_kinds_for_ft = {
              default = [ "imports" "comment" ];
              json = [ "array" ];
              c = [ "comment" "region" ];
            };
            provider_selector.__raw = ''
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
        otter = {
          enable = true;
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
              executable.command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
              executable.args = [
                "--liblldb"
                "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.dylib"
                "--port"
                "1337"
              ];
              type = "server";
              port = "1337";
              host = "127.0.0.1";
            };
          } else {
            settings.dap.adapter.command = "${pkgs.lldb_19}/bin/lldb-dap";
            settings.dap.adapter.type = "executable";
          })
        ];
        snacks = {
          enable = true;
          settings = {
            bigfile.enabled = true;
            notifier.enabled = true;
          };
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
        };
        treesitter = {
          enable = true;
          nixGrammars = true;
          package = cfg.treesitter.package;
          grammarPackages = treesitterGrammars cfg.treesitter.grammarPackageSet cfg.treesitter.package;
          settings.highlight.enable = true;
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
        tmux-navigator.enable = cfg.splitNavigator == "tmux-navigator";
        smart-splits.enable = cfg.splitNavigator == "smart-splits";
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
      keymaps = import ./vim/keymaps.nix;
      extraPlugins = with pkgs.vimPlugins; [
        (if cfg.auto-dark-mode then
          {
            plugin = (fromGitHub "f-person/auto-dark-mode.nvim" "2024-nov-19" "4531f8b2b09ed8f0b8875a706419f9cecda1d969");
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
          plugin = (fromGitHub "chrishrb/gx.nvim" "0.7.0" "4136a82a48e8601fe8f2fde5d2ac2d706ac6d0b6");
          config = mkLua ''require("gx").setup()'';
        }
        # kmonad-vim
        (mkIf (cfg.completionPlugin == "cmp") {
          plugin = luasnip;
          config = mkLua ''require("luasnip/loaders/from_vscode").lazy_load()'';
        })
        # {
        #   plugin = (fromGitHub "klen/nvim-test" "1.4.1" "e06f3d029ee161f3ead6193cf27354d1eb8723c3");
        #   config = mkLuaFile ./vim/plugins/nvim-test.lua;
        # }
        # {
        #   plugin = markview-nvim;
        #   config = mkLuaFile ./vim/plugins/markview.lua;
        # }
        plenary-nvim
        (fromGitHub "ibhagwan/smartyank.nvim" "2024nov10" "0a4554a4ea4cad73dab0a15e559f2128ca03c7b2")
        {
          plugin = toggleterm-nvim;
          config = mkLuaFile ./vim/plugins/toggleterm.lua;
        }
        {
          plugin = vim-rsi;
          config = mkLua '''';
        }
        {
          plugin = (fromGitHub "TaDaa/vimade" "2024-11-12" "57512f7eb4dfa0ef0e2f11a7b47c8c37600943f0");
          config = mkLuaFile ./vim/plugins/vimade.lua;
        }
      ] ++ (if cfg.lsp.servers.roslyn then [{
        plugin = roslyn-nvim;
        config = mkLua ''require("roslyn").setup({})'';
      }] else [ ]);
      extraConfigLua =
        (builtins.readFile ./vim/init.lua) +
        (builtins.readFile ./vim/plugins/persistence.lua);
    };
    home.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      nv = "nvim";
    };
  };
}
