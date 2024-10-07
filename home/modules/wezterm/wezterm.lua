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

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return 'Dark'
end

function scheme_for_appearance(appearance)
	if appearance:find 'Dark' then
		return 'rose-pine'
	else
		return 'rose-pine-dawn'
	end
end

local function toggle_fullscreen(window, pane)
	window:toggle_fullscreen()
end

local config                 = {
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

config.color_scheme          = scheme_for_appearance(get_appearance()) -- auto refresh on system change

config.font                  = wezterm.font_with_fallback({
	"JetBrains Mono",
	{ family = "Symbols Nerd Font Mono", scale = 0.95 },
})
config.font_size             = "FONT_SIZE"

config.keys                  = {
	{ key = "t", mods = "CMD", action = wezterm.action_callback(themePicker) },
	{ key = "f", mods = "CMD", action = wezterm.action_callback(toggle_fullscreen) },
	{ key = "d", mods = "CMD", action = wezterm.action.ShowDebugOverlay },
	-- Turn off the default CMD-x actions
	{ key = 'h', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment, },
	{ key = 'm', mods = 'CMD', action = wezterm.action.DisableDefaultAssignment, },

	-- To send in opt-{asdf} to have harpoon binds work
	{ key = 'f', mods = 'ALT', action = wezterm.action.SendKey { key = 'f', mods = 'ALT' }, },
	{ key = 'd', mods = 'ALT', action = wezterm.action.SendKey { key = 'd', mods = 'ALT' }, },
	{ key = 's', mods = 'ALT', action = wezterm.action.SendKey { key = 's', mods = 'ALT' }, },
	{ key = 'a', mods = 'ALT', action = wezterm.action.SendKey { key = 'a', mods = 'ALT' }, },
}

config.enable_kitty_keyboard = true

-- for debugging key events
-- config.debug_key_events = true

--  start in fullscreen mode, disabled for now
-- wezterm.on('gui-startup', function(window)
-- 	local mux               = wezterm.mux
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- 	local gui_window        = window:gui_window();
-- 	gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
-- end)

wezterm.plugin.require("https://gitlab.com/xarvex/presentation.wez").apply_to_config(config, {
	font_size_multiplier = 1.8,               -- sets for both "presentation" and "presentation_full"
	presentation = {
		keybind = { key = "p", mods = "SHIFT|CMD" } -- setting a keybind
	},
	presentation_full = {
		keybind = { key = "p", mods = "CMD" } -- setting a keybind
	}
})

return config
