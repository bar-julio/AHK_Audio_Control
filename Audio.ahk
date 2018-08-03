;Global Variables
devs := []
devs.push("Headphones")
devs.push("HDMI")
flag := 1
; Volume control (turn master volume up and down with Ctrl-Alt-Up/Down
^!Up::Send {Volume_Up}
^!Down::Send {Volume_Down}
; Change Audio Output Device (Ctrl-Alt-PgDown)
^!PgDn::function()

function()
{
	global flag
	global devs
	next := devs[flag]
	run, %comspec% /c nircmd setdefaultsounddevice %next% 1, C:\ ,hide
	msgbox, 524320, Audio Device, % "Now " . devs[flag] . " is selected", 1
	if (flag != devs.MaxIndex()) {
		flag := flag + 1
	} else {
		flag := 1
	}
	
}