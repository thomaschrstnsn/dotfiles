local generating = false

local function generate_description()
	if generating then
		Snacks.notify("Already generating...", { level = "warn", title = "jj-ai-describe" })
		return
	end

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
		Snacks.notify("Could not find 'JJ: Change ID:'", { level = "error", title = "jj-ai-describe" })
		return
	end

	generating = true
	local notif_id = "jj-ai-describe-progress"
	Snacks.notify("Generating description...", {
		id = notif_id,
		title = "jj-ai-describe",
		timeout = false,
	})

	vim.system({ "jj-ai-describe", change_id }, { text = true }, function(result)
		vim.schedule(function()
			generating = false
			Snacks.notifier.hide(notif_id)

			if not vim.api.nvim_buf_is_valid(bufnr) then
				Snacks.notify("Buffer no longer valid", { level = "warn", title = "jj-ai-describe" })
				return
			end

			if result.code ~= 0 then
				local err_output = result.stderr ~= "" and result.stderr or result.stdout
				Snacks.notify(err_output, {
					title = "jj-ai-describe failed",
					level = "error",
					timeout = false,
				})
				return
			end

			-- Split the script output into a table of lines.
			local new_lines = vim.split(result.stdout, "\n", { plain = true, trimempty = false })

			-- If the script output ends with a newline, vim.split will produce an extra empty string at the end.
			-- We remove it to avoid an extra blank line at the bottom of the file.
			if new_lines[#new_lines] == "" then
				table.remove(new_lines)
			end

			for _, line in ipairs(jj_lines) do
				table.insert(new_lines, line)
			end

			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
			Snacks.notify("Description generated", { title = "jj-ai-describe" })
		end)
	end)
end

vim.api.nvim_create_user_command("JjGenerateChangeDesc", generate_description, {
	desc = "Generate change description for jj",
})

vim.keymap.set("n", "<leader>a", "<cmd>JjGenerateChangeDesc<cr>", { desc = "describe jj change", buffer = true })
