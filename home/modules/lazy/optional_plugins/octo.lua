-- octo.nvim with a jj-aware PR review flow.
--
-- :OctoReviewPr <number|url>
--   1. verifies the PR belongs to the current repo (errors otherwise)
--   2. if the working copy is not already on the PR head commit:
--      fetches + tracks the head bookmark and `jj new`s on top of it
--   3. opens the PR in octo and starts/resumes a review
--
-- Octo detects "am I on the PR branch" via `git rev-parse @{u}`, which never
-- works in a jj repo (detached HEAD). We patch that check so `use_local_fs`
-- puts real files (with LSP) on the right side of the review diff.

local REMOTE = "origin"

local function run(cmd)
	local res = vim.system(cmd, { text = true }):wait()
	local out = vim.trim(res.stdout or "")
	if res.code ~= 0 then
		return nil, vim.trim(res.stderr or "") ~= "" and vim.trim(res.stderr) or out
	end
	return out
end

local function err(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "OctoReviewPr" })
end

local function info(msg)
	vim.notify(msg, vim.log.levels.INFO, { title = "OctoReviewPr" })
end

--- true when @ or @- is exactly the given commit
local function wc_at_commit(commit_id)
	if not commit_id or commit_id == "" then
		return false
	end
	local out = run({
		"jj",
		"log",
		"--ignore-working-copy",
		"--no-graph",
		"-r",
		string.format("(@ | @-) & commit_id(%s)", commit_id),
		"-T",
		"commit_id",
	})
	return out ~= nil and out ~= ""
end

--- parse "123", "#123" or "https://github.com/owner/repo/pull/123[/...]"
local function parse_target(arg)
	local num = arg:match("^#?(%d+)$")
	if num then
		return tonumber(num), nil
	end
	local repo, n = arg:match("github%.com/([^/]+/[^/]+)/pull/(%d+)")
	if repo then
		return tonumber(n), repo
	end
	return nil, nil
end

local function wait_for_octo_pr_buffer(bufnr, cb, timeout_ms)
	local deadline = vim.uv.now() + (timeout_ms or 20000)
	local function poll()
		local ok, buffer = pcall(function()
			return octo_buffers[bufnr]
		end)
		if ok and buffer and buffer.node then
			return cb()
		end
		if vim.uv.now() > deadline then
			return err("Timed out waiting for octo to load the PR")
		end
		vim.defer_fn(poll, 100)
	end
	poll()
end

local function review_pr(arg)
	local number, url_repo = parse_target(vim.trim(arg or ""))
	if not number then
		return err("Usage: :OctoReviewPr <number|github PR url>")
	end

	local repo, repo_err = run({ "gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner" })
	if not repo then
		return err("Could not determine current GitHub repo: " .. repo_err)
	end
	if url_repo and url_repo:lower() ~= repo:lower() then
		return err(string.format("PR is for %s, but current repo is %s", url_repo, repo))
	end

	local json, pr_err = run({
		"gh",
		"pr",
		"view",
		tostring(number),
		"--repo",
		repo,
		"--json",
		"headRefName,headRefOid,isCrossRepository",
	})
	if not json then
		return err(string.format("Could not fetch PR #%d: %s", number, pr_err))
	end
	local pr = vim.json.decode(json)

	if not wc_at_commit(pr.headRefOid) then
		if pr.isCrossRepository then
			return err("PRs from forks are not supported (head branch is not on " .. REMOTE .. ")")
		end
		local head = pr.headRefName
		info(string.format("Fetching %s@%s ...", head, REMOTE))
		local _, fetch_err = run({ "jj", "git", "fetch", "--remote", REMOTE, "--branch", "exact:" .. head })
		if fetch_err then
			return err("jj git fetch failed: " .. fetch_err)
		end
		-- creates the local bookmark; harmless if already tracked
		run({ "jj", "bookmark", "track", head .. "@" .. REMOTE })
		local _, new_err = run({ "jj", "new", head .. "@" .. REMOTE })
		if new_err then
			return err("jj new failed: " .. new_err)
		end
		if not wc_at_commit(pr.headRefOid) then
			return err(string.format("Working copy is not on PR head %s after checkout", pr.headRefOid:sub(1, 12)))
		end
		vim.cmd("checktime")
		info(string.format("Working copy is now on top of %s", head))
	end

	vim.cmd("edit " .. require("octo.utils").get_pull_request_uri(number, repo))
	local bufnr = vim.api.nvim_get_current_buf()
	wait_for_octo_pr_buffer(bufnr, function()
		if vim.api.nvim_get_current_buf() ~= bufnr then
			vim.api.nvim_set_current_buf(bufnr)
		end
		require("octo.reviews").start_or_resume_review()
	end)
end

return {
	{
		"pwntester/octo.nvim",
		opts = {
			use_local_fs = true,
		},
		config = function(_, opts)
			require("octo").setup(opts)

			local utils = require("octo.utils")
			local git_in_pr_branch = utils.in_pr_branch
			utils.in_pr_branch = function(pr)
				local head = pr and pr.right and pr.right.commit
				return wc_at_commit(head) or git_in_pr_branch(pr)
			end

			vim.api.nvim_create_user_command("OctoReviewPr", function(cmd)
				review_pr(cmd.args)
			end, { nargs = 1, desc = "Check out PR with jj and start an octo review" })
		end,
		cmd = { "Octo", "OctoReviewPr" },
		keys = {
			-- keep the snacks gh pickers (plugins/gh.lua) on these
			{ "<leader>gi", false },
			{ "<leader>gI", false },
			{ "<leader>gp", false },
			{ "<leader>gP", false },
			{
				"<leader>gR",
				function()
					vim.ui.input({ prompt = "PR number or URL: " }, function(input)
						if input and input ~= "" then
							vim.cmd("OctoReviewPr " .. input)
						end
					end)
				end,
				desc = "Review PR (Octo + jj)",
			},
		},
	},
}
