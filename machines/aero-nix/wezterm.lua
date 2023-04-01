local wezterm = require 'wezterm'
local act = wezterm.action

return {
  send_composed_key_when_left_alt_is_pressed = true,
  color_scheme = 'tokyonight',
  font_size = 11.5,
  window_decorations = 'RESIZE',
  hide_tab_bar_if_only_one_tab = true,
  keys = {
	-- does not seem to be working
	{
      key = 'd',
      mods = 'SUPER',
      action = act.SplitHorizontal {domain = 'CurrentPaneDomain'},
    },
	{
      key = 'd',
      mods = 'SUPER|SHIFT',
      action = act.SplitVertical {domain = 'CurrentPaneDomain'},
    },
  },
}
