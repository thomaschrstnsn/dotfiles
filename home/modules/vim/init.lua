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
            char = '│',
            show_trailing_blankline_indent = false,
        }
