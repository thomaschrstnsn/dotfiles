local rt = require("rust-tools")

rt.setup({
	tools = {
		executor = require("rust-tools.executors").quickfix,
	},
})

rt.inlay_hints.set()
rt.inlay_hints.enable()
rt.runnables.runnables()

