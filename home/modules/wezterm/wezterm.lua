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

local light_theme = 'rose-pine-dawn'
local dark_theme = 'rose-pine'

function scheme_for_appearance(appearance)
	if appearance:find 'Dark' then
		return dark_theme
	else
		return light_theme
	end
end

local function toggle_fullscreen(window, pane)
	window:toggle_fullscreen()
end

local function enable_mux(config)
	local function is_vim(pane)
		-- this is set by the plugin, and unset on ExitPre in Neovim
		return pane:get_user_vars().IS_NVIM == 'true'
	end

	local direction_keys = {
		Left = 'h',
		Down = 'j',
		Up = 'k',
		Right = 'l',
		-- reverse lookup
		h = 'Left',
		j = 'Down',
		k = 'Up',
		l = 'Right',
	}

	local function split_nav(resize_or_move, key)
		return {
			key = key,
			mods = resize_or_move == 'resize' and 'META' or 'CTRL',
			action = wezterm.action_callback(function(win, pane)
				if is_vim(pane) then
					-- pass the keys through to vim/nvim
					win:perform_action({
						SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
					}, pane)
				else
					if resize_or_move == 'resize' then
						win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
					else
						win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
					end
				end
			end),
		}
	end


	config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }
	config.keys = {
		-- splitting
		{
			mods   = "LEADER",
			key    = '"',
			action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
		},
		{
			mods   = "LEADER",
			key    = "%",
			action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
		},
		{
			mods = 'LEADER',
			key = 'z',
			action = wezterm.action.TogglePaneZoomState
		},
		-- activate copy mode or vim mode
		{
			key = '[',
			mods = 'LEADER',
			action = wezterm.action.ActivateCopyMode
		},
		split_nav('move', 'h'),
		split_nav('move', 'j'),
		split_nav('move', 'k'),
		split_nav('move', 'l'),

	}


	return {
		keys = {
			-- move between split panes
			split_nav('move', 'h'),
			split_nav('move', 'j'),
			split_nav('move', 'k'),
			split_nav('move', 'l'),
			-- resize panes
			-- split_nav('resize', 'h'),
			-- split_nav('resize', 'j'),
			-- split_nav('resize', 'k'),
			-- split_nav('resize', 'l'),
		},
	}
end

local config         = {
	warn_about_missing_glyphs    = false,
	window_decorations           = 'WINDOW_DECORATIONS',
	hide_tab_bar_if_only_one_tab = true,

	visual_bell                  = {
		fade_in_function = 'EaseIn',
		fade_in_duration_ms = 50,
		fade_out_function = 'EaseOut',
		fade_out_duration_ms = 50,
	},
	audible_bell                 = 'Disabled',
}

local auto_dark_mode = "AUTO_DARK_MODE"
if auto_dark_mode then
	config.color_scheme = scheme_for_appearance(get_appearance()) -- auto refresh on system change
else
	config.color_scheme = dark_theme;
end

config.window_background_opacity = "WINDOW_BACKGROUND_OPACITY"
config.text_background_opacity = "TEXT_BACKGROUND_OPACITY"

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

-- CONFIG_OVERRIDES_HERE

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
	font_size_multiplier = 1.0,               -- sets for both "presentation" and "presentation_full"
	presentation = {
		keybind = { key = "p", mods = "SHIFT|CMD" } -- setting a keybind
	},
	presentation_full = {
		keybind = { key = "p", mods = "CMD" } -- setting a keybind
	}
})

local USE_MUX = "USE_MUX"
if USE_MUX then
	enable_mux(config)
end

return config
