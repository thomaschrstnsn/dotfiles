local Fade = require('vimade.style.fade').Fade
local animate = require('vimade.style.value.animate')
require('vimade').setup {
	style = {
		Fade {
			value = animate.Number {
				start = 1,
				to = 0.5
			}
		}
	},
	ncmode = 'windows'
}
