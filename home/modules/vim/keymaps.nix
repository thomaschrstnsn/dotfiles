[
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
  { key = "<leader>g"; action = "<cmd>lua Lazygit_toggle()<CR>"; }
  { key = "<leader>J"; action = "<cmd>lua Lazyjj_toggle()<CR>"; }
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
]
