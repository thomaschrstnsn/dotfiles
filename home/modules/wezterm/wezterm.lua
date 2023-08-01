local wezterm = require 'wezterm'

return {
  send_composed_key_when_left_alt_is_pressed = true,
  color_scheme = 'tokyonight',
  font = wezterm.font_with_fallback({
	  "JetBrains Mono",
	  { family = "Symbols Nerd Font Mono", scale = 0.8 },
  }),
  font_size = ##FONTSIZE##,
  window_decorations = 'RESIZE',
  hide_tab_bar_if_only_one_tab = true,
}
