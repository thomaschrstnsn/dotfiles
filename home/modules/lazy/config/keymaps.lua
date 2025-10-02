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

-- Pretty-print Rust Debug output via rustfmt and show it in a new scratch buffer.
-- Works on visual selection that looks like {:?} output (struct/enum literals, arrays, etc).
-- kind: nil => :new (horizontal), 'v' => :vnew (vertical)
-- opts.edition: Rust edition for rustfmt (default '2021')
-- opts.extra_args: extra rustfmt args, e.g. { '--config', 'max_width=100' }
local function rust_debugfmt_selection_to_new(kind, opts)
	opts = opts or {}
	local edition = opts.edition or "2021"

	-- 1) Get exact visual selection (charwise/linewise; either direction)
	local s = vim.fn.getpos("'<")
	local e = vim.fn.getpos("'>")
	if s[2] > e[2] or (s[2] == e[2] and s[3] > e[3]) then
		s, e = e, s
	end

	local lines = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
	if #lines == 0 then
		vim.notify("No selection", vim.log.levels.WARN)
		return
	end
	if #lines == 1 then
		lines[1] = string.sub(lines[1], s[3], e[3])
	else
		lines[1] = string.sub(lines[1], s[3])
		lines[#lines] = string.sub(lines[#lines], 1, e[3])
	end
	local input = table.concat(lines, "\n")

	-- 2) Wrap selection as a Rust expression so rustfmt can format it nicely.
	--    We'll format:
	--      fn _fmt(){ let _x = <SELECTION>; }
	local wrapped = ("fn _fmt(){\n    let _x = %s;\n}\n"):format(input)

	local args = { "rustfmt", "--edition", edition, "--emit", "stdout" }
	if opts.extra_args then
		for _, a in ipairs(opts.extra_args) do
			table.insert(args, a)
		end
	end

	local out, err, code
	if vim.system then
		local r = vim.system(args, { stdin = wrapped }):wait()
		out, err, code = r.stdout or "", r.stderr or "", r.code or 0
	else
		out = vim.fn.system(args, wrapped)
		err = (vim.v.shell_error ~= 0) and out or ""
		code = vim.v.shell_error
	end
	if code ~= 0 then
		vim.notify("rustfmt error: " .. (err:gsub("%s+$", "")), vim.log.levels.ERROR)
		return
	end

	-- 3) Extract the formatted expression from the formatted wrapper.
	local ls = vim.split(out:gsub("\r\n", "\n"), "\n", { plain = true })

	-- Find the "let _x =" line
	local start_idx
	for i, l in ipairs(ls) do
		if l:find("let%s+_x%s*=") then
			start_idx = i
			break
		end
	end
	if not start_idx then
		vim.notify("Could not locate formatted expression", vim.log.levels.ERROR)
		return
	end

	-- First line: take content after "= "
	local expr_lines = {}
	local first = ls[start_idx]
	local first_part = first:match("let%s+_x%s*=%s*(.*)") or ""
	table.insert(expr_lines, first_part)

	-- Gather subsequent lines up to the terminating semicolon
	local i = start_idx + 1
	local end_found = false
	while i <= #ls do
		local l = ls[i]
		if l:find("^%s*}%s*$") then
			break
		end -- end of fn
		table.insert(expr_lines, l)
		if l:find(";[%s]*$") then
			-- remove trailing semicolon on the last line
			expr_lines[#expr_lines] = expr_lines[#expr_lines]:gsub("%s*;%s*$", "")
			end_found = true
			break
		end
		i = i + 1
	end
	if not end_found then
		vim.notify("Unexpected end while extracting expression", vim.log.levels.WARN)
	end

	-- Deindent continuation lines uniformly
	local min_indent = math.huge
	for j = 2, #expr_lines do
		local ws = expr_lines[j]:match("^(%s*)") or ""
		if #ws < min_indent then
			min_indent = #ws
		end
	end
	if min_indent ~= math.huge then
		for j = 2, #expr_lines do
			local ws = expr_lines[j]:match("^(%s*)") or ""
			local cut = math.min(#ws, min_indent)
			expr_lines[j] = expr_lines[j]:sub(cut + 1)
		end
	end

	-- Clean trailing blank
	if #expr_lines > 0 and expr_lines[#expr_lines]:match("^%s*$") then
		table.remove(expr_lines)
	end
	local pretty = table.concat(expr_lines, "\n")

	-- 4) Open new scratch buffer and show result
	if kind == "v" then
		vim.cmd("vnew")
	else
		vim.cmd("new")
	end
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.bo.filetype = "rust"
	vim.bo.modifiable = true

	local out_lines = vim.split(pretty, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, out_lines)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	vim.bo.modifiable = false
end

vim.keymap.set("x", "<leader>rd", function()
	rust_debugfmt_selection_to_new("v", { edition = "2021" })
end, { silent = true, desc = "Pretty-print Rust Debug output → new scratch buffer" })
