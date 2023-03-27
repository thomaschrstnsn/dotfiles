local wezterm = require 'wezterm'
local act = wezterm.action

return {
  send_composed_key_when_left_alt_is_pressed = true,
  color_scheme = 'tokyonight',
  font = wezterm.font_with_fallback({
	  "JetBrains Mono",
	  { family = "Symbols Nerd Font Mono", scale = 0.8 },
  }),
  font_size = 15,
  window_decorations = 'RESIZE',
  hide_tab_bar_if_only_one_tab = true,
  keys = {
	{
      key = 'd',
      mods = 'CMD',
      action = act.SplitHorizontal {domain = 'CurrentPaneDomain'},
    },
	{
      key = 'd',
      mods = 'CMD|SHIFT',
      action = act.SplitVertical {domain = 'CurrentPaneDomain'},
    },
  },
}
