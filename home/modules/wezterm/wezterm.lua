local wezterm = require 'wezterm'

return {
	send_composed_key_when_left_alt_is_pressed = true,
	color_scheme = 'tokyonight',
	font = wezterm.font_with_fallback({
		"JetBrains Mono",
		{ family = "Symbols Nerd Font Mono", scale = 0.8 },
	}),
	font_size = "FONTSIZE",
	window_decorations = 'RESIZE',
	hide_tab_bar_if_only_one_tab = true,
	visual_bell = {
		fade_in_function = 'EaseIn',
		fade_in_duration_ms = 150,
		fade_out_function = 'EaseOut',
		fade_out_duration_ms = 150,
	},
	audible_bell = 'Disabled',
}
