local map = vim.keymap.set

map("n", "<leader><leader>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open Oil file-browser" })
map("n", "H", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

map("n", "<leader>/", function()
	Snacks.picker.lines()
end, { desc = "Search lines in buffer" })

map("n", '<leader>"', "<C-W>s", { desc = "Split window below" })
map("n", "<leader>%", "<C-W>v", { desc = "Split window right" })

map("n", "<leader>a", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Code action" })

map("n", "<leader>sa", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

map("n", "<leader>co", "<cmd>Trouble symbols toggle focus=true<cr>", { desc = "Trouble symbols outline" })
map(
	"n",
	"<leader>cL",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "Trouble references hover" }
)

-- Send the current visual selection through jq and open the result
-- in a new *scratch* JSON buffer (no file, wiped on hide, no swap).
-- kind: nil -> horizontal split (:new), 'v' -> vertical split (:vnew)
-- jq_args: e.g. { '-S', '.' } (default), or { '-c', '.' } for compact
local function jq_selection_to_new(kind, jq_args)
	-- 1) Capture exact visual selection (handles charwise & linewise)
	local s = vim.fn.getpos("'<") -- {buf, lnum, col, off}
	local e = vim.fn.getpos("'>")

	-- Ensure start <= end even if selection was made backwards
	if s[2] > e[2] or (s[2] == e[2] and s[3] > e[3]) then
		s, e = e, s
	end

	local lines = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
	if #lines == 0 then
		vim.notify("No selection", vim.log.levels.WARN)
		return
	end

	if #lines == 1 then
		-- single-line selection: slice from s.col..e.col
		lines[1] = string.sub(lines[1], s[3], e[3])
	else
		-- multi-line selection: trim first & last lines to columns
		lines[1] = string.sub(lines[1], s[3])
		lines[#lines] = string.sub(lines[#lines], 1, e[3])
	end
	local input = table.concat(lines, "\n")

	-- 2) Run jq
	jq_args = jq_args or { "-S", "." }
	local out, err, code
	if vim.system then
		local r = vim.system(vim.list_extend({ "jq" }, jq_args), { stdin = input }):wait()
		out, err, code = r.stdout or "", r.stderr or "", r.code or 0
	else
		out = vim.fn.system(vim.list_extend({ "jq" }, jq_args), input)
		err = (vim.v.shell_error ~= 0) and out or ""
		code = vim.v.shell_error
	end
	if code ~= 0 then
		vim.notify("jq error: " .. (err:gsub("%s+$", "")), vim.log.levels.ERROR)
		return
	end

	-- 3) Open a new window and configure a *scratch* JSON buffer
	if kind == "v" then
		vim.cmd("vnew")
	else
		vim.cmd("new")
	end
	-- scratch buffer settings
	vim.bo.buftype = "nofile" -- not associated with a file on disk
	vim.bo.bufhidden = "wipe" -- wipe buffer when hidden
	vim.bo.swapfile = false -- no swapfile
	vim.bo.filetype = "json"
	vim.bo.modifiable = true

	-- 4) Insert jq output
	local new_lines = vim.split(out:gsub("\r\n", "\n"), "\n", { plain = true })
	if #new_lines > 0 and new_lines[#new_lines] == "" then
		table.remove(new_lines) -- drop trailing empty line if present
	end
	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	vim.bo.modifiable = false
end

map("x", "<leader>j", function()
	jq_selection_to_new("v")
end, { silent = true, desc = "Filter visual selection through jq → new json buffer" })
