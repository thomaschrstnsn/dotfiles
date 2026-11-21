-- C#/.NET IDE support layered on LazyVim's lang.dotnet extra.
--
-- The extra brings treesitter (c_sharp, fsharp), csharpier/fantomas formatting,
-- fsautocomplete, a netcoredbg DAP adapter and neotest-vstest. On top of that:
--   * Roslyn (seblyng/roslyn.nvim + nixpkgs roslyn-ls) replaces OmniSharp
--   * DAP launches pick a built project dll instead of asking for a path,
--     and run with the project directory as cwd (so appsettings.json loads)
--   * a `coreclr` adapter so roslyn's "Debug Test" code lens works

local ROSLYN_BIN = "Microsoft.CodeAnalysis.LanguageServer" -- binary name in nixpkgs roslyn-ls

local function is_project_file(name)
	return name:match("%.csproj$") ~= nil or name:match("%.fsproj$") ~= nil
end

--- <project>/bin/Debug/<tfm>/<project>.dll for every project under cwd
local function project_dlls()
	local dlls = {}
	local projects = vim.fs.find(is_project_file, {
		path = vim.fn.getcwd(),
		type = "file",
		limit = math.huge,
	})
	for _, proj in ipairs(projects) do
		local dir = vim.fs.dirname(proj)
		local name = vim.fn.fnamemodify(proj, ":t:r")
		vim.list_extend(dlls, vim.fn.glob(dir .. "/bin/Debug/*/" .. name .. ".dll", false, true))
	end
	return dlls
end

local function pick_dll()
	local dap = require("dap")
	local dlls = project_dlls()
	if #dlls == 0 then
		local path = vim.fn.input("Path to dll (nothing built?): ", vim.fn.getcwd() .. "/", "file")
		return path ~= "" and path or dap.ABORT
	end
	if #dlls == 1 then
		return dlls[1]
	end
	return coroutine.create(function(co)
		vim.ui.select(dlls, {
			prompt = "Debug dll",
			format_item = function(path)
				return vim.fn.fnamemodify(path, ":.")
			end,
		}, function(choice)
			coroutine.resume(co, choice or dap.ABORT)
		end)
	end)
end

local function netcoredbg_adapter()
	return {
		type = "executable",
		command = vim.fn.exepath("netcoredbg"),
		args = { "--interpreter=vscode" },
		options = { detached = false },
		-- default cwd to the dll's project dir (content root for ASP.NET)
		enrich_config = function(config, on_config)
			if config.request == "launch" and type(config.program) == "string" and config.cwd == nil then
				config = vim.deepcopy(config)
				config.cwd = vim.fs.root(config.program, is_project_file) or vim.fn.getcwd()
			end
			on_config(config)
		end,
	}
end

-- csharpier / fantomas / fsautocomplete are opt-in on the Nix side
local function has(bin)
	return vim.fn.executable(bin) == 1
end

return {
	-- Roslyn instead of OmniSharp
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				omnisharp = { enabled = false },
				fsautocomplete = { enabled = has("fsautocomplete") },
			},
		},
	},

	-- drop formatters that aren't installed; cs then falls back to roslyn (.editorconfig)
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			if not has("csharpier") then
				opts.formatters_by_ft.cs = nil
			end
			if not has("fantomas") then
				opts.formatters_by_ft.fsharp = nil
			end
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		optional = true,
		opts = function(_, opts)
			opts.sources = vim.tbl_filter(function(source)
				local name = source.name
				return not ((name == "csharpier" or name == "fantomas") and not has(name))
			end, opts.sources or {})
		end,
	},
	{
		"seblyng/roslyn.nvim",
		ft = { "cs", "razor" },
		---@module 'roslyn.config'
		---@type RoslynNvimConfig
		opts = {
			-- also find solutions that live beside (not above) the opened project
			broad_search = true,
		},
		-- init, not config: the plugin's plugin/roslyn.lua runs vim.lsp.enable("roslyn")
		-- on load, which validates cmd before config() would get to override it
		init = function()
			vim.lsp.config("roslyn", {
				-- the nixpkgs binary is the server itself, not the roslyn-language-server
				-- thin client, so it has no --daemon-mode
				cmd = {
					ROSLYN_BIN,
					"--stdio",
					"--logLevel=Information",
					"--clientProcessId",
					tostring(vim.uv.os_getpid()),
					"--extensionLogDirectory",
					vim.fs.joinpath(vim.fn.stdpath("log"), "roslyn"),
				},
				settings = {
					["csharp|background_analysis"] = {
						dotnet_analyzer_diagnostics_scope = "openFiles",
						dotnet_compiler_diagnostics_scope = "fullSolution",
					},
					["csharp|code_lens"] = {
						dotnet_enable_references_code_lens = true,
						dotnet_enable_tests_code_lens = true,
					},
					["csharp|completion"] = {
						dotnet_show_completion_items_from_unimported_namespaces = true,
						dotnet_show_name_completion_suggestions = true,
					},
					["csharp|inlay_hints"] = {
						csharp_enable_inlay_hints_for_implicit_object_creation = true,
						csharp_enable_inlay_hints_for_implicit_variable_types = true,
						csharp_enable_inlay_hints_for_lambda_parameter_types = true,
						csharp_enable_inlay_hints_for_types = true,
						dotnet_enable_inlay_hints_for_parameters = true,
					},
					["csharp|navigation"] = {
						dotnet_navigate_to_decompiled_sources = true,
					},
					["csharp|symbol_search"] = {
						dotnet_search_reference_assemblies = true,
					},
				},
				on_attach = function(_, bufnr)
					-- code lenses (references, run/debug test) are off until toggled with H;
					-- <leader>cc runs the lens under the cursor
					vim.keymap.set("n", "<leader>cT", "<cmd>Roslyn target<cr>", {
						buffer = bufnr,
						desc = "Roslyn: choose solution",
					})
				end,
			})
		end,
	},

	-- Debugging (runs after the extra's opts, so these win)
	{
		"mfussenegger/nvim-dap",
		optional = true,
		opts = function()
			local dap = require("dap")
			dap.adapters.netcoredbg = netcoredbg_adapter()
			dap.adapters.coreclr = netcoredbg_adapter() -- name roslyn's "Debug Test" lens expects

			local configs = {
				{
					type = "coreclr",
					name = "Launch project",
					request = "launch",
					program = pick_dll,
					env = { ASPNETCORE_ENVIRONMENT = "Development", DOTNET_ENVIRONMENT = "Development" },
				},
				{
					type = "coreclr",
					name = "Attach to process",
					request = "attach",
					processId = function()
						return require("dap.utils").pick_process()
					end,
				},
			}
			for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
				dap.configurations[lang] = configs
			end
		end,
	},
}
