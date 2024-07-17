local function handle_references_response(result)
	vim.cmd("Trouble lsp_references toggle focus=true")
end

require("definition-or-references").setup({
	on_references_result = handle_references_response,
})
