if input volume of (get volume settings) = 0 then
	set volume input volume 100
	display notification "Volume set to 100" with title "✅ Microphone is on"
else
	set volume input volume 0 without output muted
	display notification "Volume set to 0" with title "❌ Microphone is muted"
end if

