-- Get the current change_id
local rev = context.change_id()
if not rev then
	flash("No revision selected")
	return
end
-- Get local bookmark for the revision
local branch, err = jj("log", "-T", "self.local_bookmarks()", "--no-graph", "-r", rev)
if err then
	flash("Error getting bookmarks: " .. err)
	return
end
branch = branch:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
if branch == "" then
	flash("Revision has no local bookmark, cannot create PR")
	return
end
-- Check if bookmark is synced with remote
local synced_output, _ = jj(
	"log",
	"-T",
	"self.local_bookmarks().any(|bm| bm.synced()) && self.remote_bookmarks().any(|bm| bm.synced())",
	"--no-graph",
	"-r",
	rev
)
local is_synced = synced_output:gsub("^%s*(.-)%s*$", "%1") == "true"
if not is_synced then
	local choice = choose({
		options = { "Ignore and continue", "Stop" },
		title = "Bookmark not synced with remote",
	})
	if choice ~= "Ignore and continue" then
		flash("PR creation cancelled")
		return
	end
end
-- Get trunk branch name
local trunk, _ = jj("log", "-T", "self.local_bookmarks()", "--no-graph", "-r", "trunk()")
trunk = trunk:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
-- Get PR title from user
local title = input({
	title = "PR Title",
	prompt = "Enter title: ",
})
if not title or title == "" then
	flash("PR creation cancelled - no title provided")
	return
end
-- Confirm creation
local confirm = choose({
	options = { "Create PR", "Cancel" },
	title = "Create PR: " .. title,
})
if confirm ~= "Create PR" then
	flash("PR creation cancelled")
	return
end
-- Create the PR using gh CLI
exec_shell("gh pr create -B " .. trunk .. " -H " .. branch .. ' --title "' .. title .. '" -w')
flash("PR created for " .. branch)
