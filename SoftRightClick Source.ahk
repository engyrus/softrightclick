#SingleInstance Force
#Maxthreads 1

; SoftRightClick 1.9A
;
; Jerry Kindall <softrightclick@jerrykindall.com> <http://www.jerrykindall.com/>
;
;	Automatically invokes right mouse button when left button is held down.
;	For use on Fujitsu LifeBook P1510D and other touch-screen PCs that don't have XP Tablet Edition.
;	Or just because you want that one-button Macintosh mouse feeling.
;
; v1.0: Initial release
; v1.1: Added ability to invoke right-click at the end of a drag (i.e for contextual menus on text selections)
;	Reduced slop factor to 5 pixels from 10
;	Made timeout easily configurable in the script by changing a variable
;	Added ability to enable/disable/exit from tray icon
; v1.2: Completely rethought algorithm for click-and-hold! Allows you to click-and-hold on selected text without
;	changing the selection! (Initial mousedown is only passed through once dragging begins.)
;	Timeout is doubled if you began by dragging to help prevent accidental drops of dragged items.
;	Slop factor is now 5 pixels total in any direction (i.e. x+y)
; v1.3: Made timeout huge (10 sec) if the stylus is dragged out of the original window to prevent dropping.
; v1.4: User-settable preferences w/ dialog; custom tray icon; tweaks to make it play better with RitePen
; v1.5: Removed a spurious left-mouseup that was interfering with right-clicking the wireless network tray icon
;       (didn't think that would have any affect but obviously it does!)
; v1.6: Reduced CPU usage dramatically. Made the Accuracy setting actually have an effect. Put prefs in HKCU,
;	where I meant to put them in the first place. Added passthru mode for initial mousedown and GUI for it.
; v1.7: Now pass through click immediately and disable timeout when clicking on scroll bars and certain controls.
;	Fixed glitches with RitePen once and for all (the trick was SetMouseDelay -1)!
; v1.8: Corner taps for forcing the next tap to be left, middle, right, or no click and GUI to enable this.
;	Checkbox in options dialog to load SoftRightClick at login and to activate it by default. Option to disable
;	drag-and-hold entirely. Now passes through second click of double-click immediately and sets drag timeout.
;	Can now drag on context menu instead of just tapping (a left-click is sent if you drag after holding).
; v1.9: On-screen indicator of impending right-click. Added force-button shortcuts to tray context menu.  
;	Removed corner-clicks.  Added mouse gestures on tray icon (tap to toggle, drag up/down for context menu, 
;	other drags for click modes).  Options dialog now appears in lower right corner of screen.  Recompiled with
;	new AHK; hopefully this will alleviate the occasional "too many hotkeys" errors. Unhook feature.
; v1.9A: Bug fix release.  Fixes bugs with tray icon, impending right-click indicator. Tray icon gestures are no
;	longer available when SoftRightClick is disabled (that didn't make any sense anyway).
; v1.9B: Added short delay after mousedown upon release if the initial mousedown didn't get passed through. Allows
;	zoom/tilt buttons in Google Earth to work better when tapped.  I THINK the "too many hotkeys" thing is finally
;	fixed for good. At least, it should be improved now... Fixed error with Unhook when in Disabled mode.
;	Added gray icon for unhook mode.  Added more reliable method of detecting taps on tray icon.
; Upcoming for v2.0: Major code refactoring.  Utilize bezel buttons for click modfication. "Light" version
; 	without GUI or graphics (to use less memory).  Finish support for auto-scrollbar disable in Moz/Opera 
;	and in DirectUI HWNDs. Installer. Pref setting for tray icon single-tap action (right-click, menu, toggle).
;	Separate icons for special click modes?

vers := "v1.9B"

CoordMode Mouse, Screen							; make coordinates relative to the screen
CoordMode Pixel, Screen
SetMouseDelay -1
SetBatchLines -1
Process Priority, , Realtime

Hotkey Escape, Off

;
; Read the preferences - HKCU first, fallback to HKLM, if neither found use hard-coded defaults
;


RegRead t1, HKCU, Software\SoftRightClick, Timeout1
If ErrorLevel
	RegRead t1, HKLM, Software\SoftRightClick, Timeout1
If ErrorLevel
	t1 := 750							; timeout to invoke right click (milliseconds)
RegRead t2, HKCU, Software\SoftRightClick, Timeout2
If ErrorLevel
	RegRead t2, HKLM, Software\SoftRightClick, Timeout2
If ErrorLevel
	t2 := 1500							; ... after dragging
RegRead t3, HKCU, Software\SoftRightClick, Timeout3
If ErrorLevel
	RegRead t3, HKLM, Software\SoftRightClick, Timeout3
If ErrorLevel
	t3 := 999999
If t3 = 99999
	t3 := 999999							; ... after dragging outside original window
RegRead pr, HKCU, Software\SoftRightClick, Precision
If ErrorLevel
	RegRead pr, HKLM, Software\SoftRightClick, Precision
If ErrorLevel
	pr := 4								; accuracy
RegRead pt, HKCU, Software\SoftRightClick, Passthru
If ErrorLevel
	RegRead pt, HKLM, Software\SoftRightClick, Passthru
If ErrorLevel
	pt := 0
RegRead dh, HKCU, Software\SoftRightClick, Draghold
If ErrorLevel
	RegRead dh, HKLM, Software\SoftRightClick, Draghold
If ErrorLevel
	dh := 1
RegRead ind, HKCU, Software\SoftRightClick, Indicator
If ErrorLevel
	RegRead ind, HKLM, Software\SoftRightClick, Indicator
If ErrorLevel
	ind := 1
su := 1
RegRead lb, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, SoftRightClick
If ErrorLevel
	su := 0
Else
	If (lb <> A_ScriptFullPath)	; key exists but it's wrong, so update it
		RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, SoftRightClick, %A_ScriptFullPath%
RegRead on, HKCU, Software\SoftRightClick, Active
If ErrorLevel
	RegRead on, HKLM, Software\SoftRightClick, Active
If ErrorLevel
	on := 1								; left button handler is initially active
lb := on
lc := 0
uh := 0									; we're not unhooked

;
; Set up system tray icon and menu
;

Menu Tray, Tip, SoftRightClick %vers%
;Menu Tray, Add, %vers%, DoExit
;Menu Tray, Disable, %vers%
Menu Tray, Add, Left, DoLeft
Menu Tray, Add, Middle, DoMiddle
Menu Tray, Add, Right, DoRight
Menu Tray, Add, Hover, DoHover
Menu Tray, Add
Menu Tray, Add, Exit, DoExit
Menu Tray, Add, Options..., DoOptions
Menu Tray, Add, Unhook, DoUnhook
Menu Tray, Add, Disable, DoDisable
Menu Tray, Default, Disable
Menu Tray, NoStandard
SetTrayIcon(2-lb)

;
; Left mouse button handler
;

$LButton::

	Critical

	MouseGetPos ix, iy, iw, ic, 1			; get initial mouse coordinates, window id
	MouseGetPos ox, oy, iw, ic2
	WinGetClass, iwc, ahk_id %iw%
	ControlGetText ict, %ic%, ahk_id %iw%
	c := A_TickCount						; get the tick count (# of ms since last startup)

	c2 := c
	c3 := c
	ds := 1								; drag start flag (if 1, drag needs to be started)
	tt := t1
	si := ind							; splash window needs to be turned on initially
	If ((pt and m=0) or m=1 or lb=0)
	{
		MouseClick Left, ix, iy, 1, , D				; pass thru mousedown
		ds := 0
	}
	Else
	{
		if (c - lc < 250)						; second click of a double-click
		{
			If (Abs(ix-lx) + Abs(iy-iy) < 10)
			{
				MouseClick Left, ix, iy, 1, , D			; pass thru mousedown
				ds := 0
				If dh						; if drag-and-hold enabled, use its timeout
					tt := t2
				Else						; otherwise no timeout
					tt := 999999
			}
		}
	}

	if (lb=0 or m=1)
	{	
		tt := 999999
		m := 0
	}
	SetTimer CancelCorner, Off
	if (m = 2)
	{
		MouseClick Right, ix, iy, 1, , D		; pass thru mousedown
		KeyWait LButton
		MouseClick Right, 0, 0, 1, , U, R
		SetTrayIcon(2-lb)
		m := 0
		Goto CleanExit
	}
	if (m = 3)
	{
		MouseClick Middle, ix, iy, 1, , D		; pass thru mousedown
		KeyWait LButton
		MouseClick Middle, 0, 0, 1, , U, R
		SetTrayIcon(2-lb)
		m := 0
		Goto CleanExit
	}
	if (m = 4)
	{
		KeyWait LButton
		SetTrayIcon(2-lb)
		m := 0
		Goto CleanExit
	}

	; Check to see if we're clicking a standard scroll bar in a standard window
	ControlGet cs, Style, , %ic2%, ahk_id %iw%			; get control style
	If (cs & 0x300000) 						; control has scrollbar
	{
		WinGetPos wx, wy, , , ahk_id %iw%			; get location of scrollbar
		ControlGetPos cx, cy, cw, ch, %ic2%, ahk_id %iw%
		cx := wx + cx + cw
		cy := wy + cy + ch
		If ((cs & 0x200000) and (cx - ix < 20) or (cs & 0x100000) and (cy - iy < 20))	; are we inside scrollbar?
		{
			MouseClick Left, ix, iy, 1, , D			; pass thru mousedown
			ds := 0
			tt := 999999					; disable timeout

		}
	}	

	; Passthrough automatically if we're clicking on certain types of controls
	if (InStr(ic2, "updown") or InStr(ic2, "scrollbar") or InStr(ic2, "trackbar"))
	{
		MouseClick Left, ix, iy, 1, , D				; pass thru mousedown
		ds := 0
		tt := 999999						; disable timeout
	}

	; Passthrough automatically for main scrollbar in IE (no way to detect other ones), fake it for Mozilla/Opera
	if (InStr(ic2, "internet explorer_server") or InStr(ic2, "mozillawindowclass") or InStr(ic2, "operawindowclass"))
	{
		WinGetPos wx, wy, , , ahk_id %iw%			; get location of scrollbar
		ControlGetPos cx, cy, cw, ch, %ic2%, ahk_id %iw%
		cx := wx + cx + cw
		If ((cx - ix < 20) and ch > 250)			; are we inside scrollbar?
		{
			MouseClick Left, ix, iy, 1, , D			; pass thru mousedown
			ds := 0
			tt := 999999					; disable timeout
		}
	}

	Sleep 0

	Loop
	{
		MouseGetPos cx, cy, cw, cc, 1				; get current mouse coordinates, window id
		if (GetKeyState("LButton", "P") = 0)			; left button has come up
		{
			lc := A_TickCount				; remember when we released (for double-click detect)
			MouseGetPos lx, ly				; and where
			SplashImage Off
			If iwc = Shell_TrayWnd				; are we clicking in system tray?
				IfInString ic, ToolbarWindow32
					IfInString ict, Notification Area
					{
						PixelGetColor fc, ox, oy
						SetTrayIcon(5)
						PixelSearch , , , ox, oy, ox, oy, 0x000000
						If ErrorLevel = 0
						{
							SetTrayIcon(6)
							PixelSearch , , , ox, oy, ox, oy, 0xFFFFFF
							If ErrorLevel = 0
							{
 								SetTrayIcon(2-lb)
								PixelSearch , , , ox, oy, ox, oy, %fc%
								If ErrorLevel = 0
								{
									if (not ds)
										MouseClick Left, , , 1, , U
									If (abs(cx-ox) + abs(cy-oy) <= pr) ; single tap
									{
										MouseClick Left, , , 2
									}
									Else ; dragged off tray icon
									{
										if (abs(cx-ox) < 10) ; drag straight up or down
										{
											MouseClick Right, ox, oy	; bring up context menu
;											MouseMove cx, cy
											Goto CleanExit
										}
										if lb
										{
											if (abs(oy-cy) < 10) ; drag straight to right or left
								 			{
												If (ox - cx > 10) ; drag to left
													Gosub DoLeft
												If (cx - ox > 10) ; drag to right
													Gosub DoRight
											}
											Else	; diagonal drag
											{
												If (ox - cx > 10) ; drag diagonally to left
													Gosub DoMiddle
												If (cx - ox > 10) ; drag diagonally to right
													Gosub DoHover				
											}
										}
									}
									Goto CleanExit
								}
							}
						}
					}

			SetTrayIcon(2-lb)
			if ds
			{
				MouseClick Left, , , 1, , D		; if we've not started dragging, pass thru mousedown
				sleep 50
			}
			MouseClick Left, , , 1, , U		; always pass thru mouseup
			Goto CleanExit
		}
		If (A_TickCount - c > tt)				; we timed out on left click+hold
		{
			SplashImage Off
			If (not ds)
				MouseClick Left, 0, 0, 1, , U, R	; if we've sent left mousedown, release it
			MouseClick Right				; click right button
			KeyWait LButton					; wait for the left button to come up
			MouseGetPos ix, iy				; if we've dragged outside the slop area...
			If (Abs(cx-ix) + Abs(cy-iy) > pr)
				MouseClick Left, ix, iy			; ... click left mouse button, we're on a menu
			lc := 0						; reset double-click timeout
			SetTrayIcon(2-lb)
			Goto CleanExit
		}
		MouseGetPos cx, cy, cw, cc, 1				; get current mouse coordinates, window id
		If (Abs(cx-ix) + Abs(cy-iy) > pr)			; mouse has moved more outside of slop box
		{
			SplashImage Off
			MouseGetPos cx, cy, cw, cc, 1			; get current mouse coordinates, window id
			If ds						; need to pass through a mousedown to start drag?
			{
				MouseClick Left, ix, iy, 1, , D 	; put the left button down at the inital location
				Sleep 0
				ds := 0
				tt := t2				
			}
			MouseGetPos cx, cy, cw, cc, 1			; get pos again; window under cursor may be splash
			If (iw <> cw or ic <> cc or not dh)		; dragged from original window or drag-hold off
				tt := t3					; ... so use third timeout (typically very long)
			c := A_TickCount				; reset timer and inital click location
			c3 := c
			ix := cx
			iy := cy
			si := ind
		}
		If (A_TickCount - c3 > tt / 2 and si) ; show indicator
		{
			six := cx - 15
			siy := cy - 15
			SplashImage %A_ScriptDir%\circle.gif, B H31 W31 X%six% Y%siy%
			si := 0
		}
		Sleep 1
	}

CleanExit:
	Hotkey $Lbutton, Toggle
	Hotkey $Lbutton, Toggle
	Exit								; just in case! (we should never get here)

;
; Menu item handler - Disable
;

DoDisable:
	Menu Tray, Tip, SoftRightClick (Disabled)
	Menu Tray, Delete, Disable
	Menu Tray, Add, Enable, DoEnable
	Menu Tray, Default, Enable
	lb :=0
	SetTrayIcon(2)
	Exit

DoUnhook:
	Menu Tray, Tip, SoftRightClick (Unhooked)
	if lb
	{
		Menu Tray, Delete, Disable
		Menu Tray, Add, Enable, DoEnable
	}
	Menu Tray, Default, Enable
	Menu Tray, Disable, Unhook
	SetTrayIcon(4)
	Hotkey $LButton, Off
	lb := 0
	uh := 1
	Exit
		
;
; Menu item handler - Enable
;

DoEnable:
	Menu Tray, Tip, SoftRightClick %vers%
	Menu Tray, Delete, Enable
	Menu Tray, Add, Disable, DoDisable
	Menu Tray, Default, Disable
	Menu Tray, Enable, Unhook
	SetTrayIcon(1)
	Hotkey $LButton, On
	lb := 1
	uh := 0
	Exit

;
; Menu item handler - Exit
;

DoExit:
	ExitApp

;
; Menu item handler - Options
;

DoOptions:
	GUI +ToolWindow -SysMenu +AlwaysOnTop
	GUI Add, Text, YM+4, Tap-and-hold timeout:
	GUI Add, Edit, W55 R1 X+5 YM+1 Number Limit4 Right
	GUI Add, UpDown, vt1 Range100-1500 +0x80, %t1%
	GUI Add, Text, X+5 YM+4, ms
	GUI Add, Checkbox, vdh XM YM+30 Checked%dh%, Drag-and-hold:
	GUI Add, Edit, W55 R1 X+19 YM+27 Number Limit4 Right
	GUI Add, UpDown, vt2 Range200-2000 +0x80, %t2%
	GUI Add, Text, X+5 YM+30, ms
	GUI Add, Text, xm ym+60, Accuracy:
	q := (pr < 4)
	GUI Add, Radio, vac x+5 Checked%q%, Precise (2px)
	q := (pr = 4)
	GUI Add, Radio, x+5 Checked%q%, Middlin' (4px)
	q := (pr > 4)
	GUI Add, Radio, x+5 Checked%q%, Sloppy (6px)
	q := (t2 = t3)
	GUI Add, Checkbox, vdr xm ym+85 Checked%q%, Continue drag-and-hold outside the window
	GUI Add, Checkbox, vpt xm ym+105 Checked%pt%, Pass through initial mousedown immediately
	GUI Add, Checkbox, vind xm ym+125 Checked%ind%, Show indicator before right-clicking
	GUI Add, Checkbox, vsu xm ym+160 Checked%su%, Load at startup
	GUI Add, Checkbox, von x+25 Checked%on%, Enabled by default
	GUI Add, Button, W60 xm+243 ym+0 Default, OK
	GUI Add, Button, W60 xm+243 ym+25, Cancel
	GUI Add, Text, xm ym+195, by Jerry Kindall
	GUI Font, Underline
	GUI Add, Text, x+36 cBlue gDoWeb, http://www.jerrykindall.com/
	GUI Font

	GUI Add, Text, x+36, %vers%

	xp := A_ScreenWidth-350
	yp := A_ScreenHeight-300
	GUI Show, x%xp% y%yp%, SoftRightClick Options
	Hotkey $LButton, Off
	Hotkey Escape, On
	Exit

;
; Click handler - URL field in Options dialog
;

DoWeb:
	GUI Destroy
	Hotkey Escape, Off
	Run http://www.jerrykindall.com/
	If (Not uh)
		HotKey $LButton, On
	Exit

;
; Button handler - OK in Options dialog
;

ButtonOK:
	GUI Submit
	GUI Destroy
	Hotkey Escape, Off
	pr := ac * 2
	if (dr)
		t3 := t2
	Else
		t3 := 999999
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Timeout1, %t1%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Timeout2, %t2%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Timeout3, %t3%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Precision, %pr%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Passthru, %pt%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Draghold, %dh%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Active, %on%
	RegWrite REG_DWORD, HKCU, Software\SoftRightClick, Indicator, %ind%
	if su
		RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, SoftRightClick, %A_ScriptFullPath%
	Else
		RegDelete HKCU, Software\Microsoft\Windows\CurrentVersion\Run, SoftRightClick
	If (Not uh)
		HotKey $LButton, On
	Exit

;
; Button handler - Cancel in Options dialog
;

ButtonCancel:
	GUI Destroy
	Hotkey Escape, Off
	If (Not uh)
		HotKey $LButton, On
	Exit

;
; Keystroke handler - Escape in Options dialog
;

Escape::
	GUI Destroy
	If (Not uh)
		HotKey $LButton, On
	Exit

;
; Timer handler - cancel corner-tap mode
;

CancelCorner:
	SetTimer CancelCorner, Off
	m :=0
	Menu Tray, Icon, SoftRightClick.icl, (2-lb)
	Exit

CancelTip:
	SetTimer CancelTip, Off
	Progress Off
	Exit
	
DoLeft:
	m := 1		; left click
	SetTrayIcon(3)
	SetTimer CancelCorner, 3000
	Exit

DoRight:
	m := 2		; right click
	SetTrayIcon(3)
	SetTimer CancelCorner, 3000
	Exit

DoMiddle:
	m := 3		; middle click
	SetTrayIcon(3)
	SetTimer CancelCorner, 3000
	Exit

DoHover:
	m := 4		; hover (no click)
	SetTrayIcon(3)
	SetTimer CancelCorner, 3000
	Exit

SetTrayIcon(icn)
{
	Menu Tray, Icon, SoftRightClick.icl, %icn%
}