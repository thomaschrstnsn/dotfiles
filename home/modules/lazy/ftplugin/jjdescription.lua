local function generate_description()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local jj_lines = {}
	local change_id = nil
	for _, line in ipairs(lines) do
		if line:match("^JJ:") then
			table.insert(jj_lines, line)
			local id = line:match("^JJ: Change ID: (%S+)")
			if id then
				change_id = id
			end
		end
	end

	if not change_id then
		vim.api.nvim_echo({ { "Error: Could not find 'JJ: Change ID:'.", "ErrorMsg" } }, false, {})
		return
	end

	local command = "jj-ai-describe " .. vim.fn.shellescape(change_id)
	local script_output = vim.fn.system(command)

	if vim.v.shell_error ~= 0 then
		local errmsg = "Error running command '" .. command .. "': " .. script_output
		vim.api.nvim_echo({ { errmsg, "ErrorMsg" } }, false, {})
		return
	end

	-- Split the script output into a table of lines.
	-- The last argument `true` keeps trailing empty lines if any.
	local new_lines = vim.split(script_output, "\n", { plain = true, trimempty = false })

	-- If the script output ends with a newline, vim.split will produce an extra empty string at the end.
	-- We remove it to avoid an extra blank line at the bottom of the file.
	if new_lines[#new_lines] == "" then
		table.remove(new_lines)
	end

	for _, line in ipairs(jj_lines) do
		table.insert(new_lines, line)
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

vim.api.nvim_create_user_command("JjGenerateChangeDesc", generate_description, {
	desc = "Generate change description for jj",
})

vim.keymap.set("n", "<leader>a", "<cmd>JjGenerateChangeDesc<cr>", { desc = "describe jj change", buffer = true })
