local wezterm = require 'wezterm'

return {
	-- https://github.com/rebelot/kanagawa.nvim/blob/master/extras/wezterm.lua
	force_reverse_video_cursor = true,
	colors = {
		foreground = "#dcd7ba",
		background = "#1f1f28",

		cursor_bg = "#c8c093",
		cursor_fg = "#c8c093",
		cursor_border = "#c8c093",

		selection_fg = "#c8c093",
		selection_bg = "#2d4f67",

		scrollbar_thumb = "#16161d",
		split = "#16161d",

		ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
		brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
		indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
	},

	font = wezterm.font_with_fallback({
		"JetBrains Mono",
		{ family = "Symbols Nerd Font Mono", scale = 0.95 },
	}),
	font_size = "FONTSIZE",
	warn_about_missing_glyphs = false,

	window_decorations = 'RESIZE',
	hide_tab_bar_if_only_one_tab = true,

	visual_bell = {
		fade_in_function = 'EaseIn',
		fade_in_duration_ms = 50,
		fade_out_function = 'EaseOut',
		fade_out_duration_ms = 50,
	},
	audible_bell = 'Disabled',
}
