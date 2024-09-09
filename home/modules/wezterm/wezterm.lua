local wezterm = require 'wezterm'
local act = wezterm.action

local function setTheme(window, _, _, label)
	wezterm.log_info("Switching to: " .. label)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = label
	window:set_config_overrides(overrides)
end

local function themePicker(window, pane)
	-- get builting color schemes
	local schemes = wezterm.get_builtin_color_schemes()
	local choices = {}

	-- populate theme names in choices list
	for key, _ in pairs(schemes) do
		table.insert(choices, { id = tostring(key), label = tostring(key) })
	end

	-- sort choices list
	table.sort(choices, function(c1, c2)
		return c1.label < c2.label
	end)

	window:perform_action(
		act.InputSelector {
			action = wezterm.action_callback(setTheme),
			title = "🎨 Pick a Theme!",
			choices = choices,
			fuzzy = true,
		},
		pane
	)
end


return {
	color_scheme                 = 'Kanagawa (Gogh)',

	font                         = wezterm.font_with_fallback({
		"JetBrains Mono",
		{ family = "Symbols Nerd Font Mono", scale = 0.95 },
	}),
	font_size                    = "FONT_SIZE",

	keys                         = {
		{ key = "t", mods = "CMD",       action = wezterm.action_callback(themePicker) },
		{ key = "t", mods = "CMD|SHIFT", action = wezterm.action.ShowDebugOverlay },
	},
	warn_about_missing_glyphs    = false,

	window_decorations           = 'RESIZE',
	hide_tab_bar_if_only_one_tab = true,

	visual_bell                  = {
		fade_in_function = 'EaseIn',
		fade_in_duration_ms = 50,
		fade_out_function = 'EaseOut',
		fade_out_duration_ms = 50,
	},
	audible_bell                 = 'Disabled',
}

