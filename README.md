# softrightclick
A Windows utility that allows you to long-click the mouse in order to right-click, intended for use with touchscreen notebooks.

Note from the author: I wrote this for myself a long time ago. It was my first major project using AutoHotkey.
The code is not very good, but it works. The original README follows.

# SoftRightClick 1.9B of February 16, 2006 by Jerry Kindall

SoftRightClick is a utility that automatically clicks the right mouse button when the left mouse button is held down. I wrote this for my Fujitsu LifeBook P1510D, which has a touch screen and can be used in a tablet orientation. Since there's no active digitizer, however, there's no side switch on the stylus to enable you to right-click, and since the machine came with XP Pro rather than XP Tablet Edition, there's no option to right-click by tapping and holding. Fujitsu's solution, a taskbar icon that you tap to make your NEXT tap a right-click, is exactly as inconvenient as it sounds.

Hence SoftRightClick, which implements a Tablet-style tap-and-hold right-click. Basically any time you are holding the stylus (left mouse button) down and not moving it for a little while, you'll get a right click. It optionally works at the end of a drag too (e.g. after selecting text).

## Installation

There's no special installation needed. Just unzip the file (it seems you've figured that part out already). If SoftRightClick is already running, exit it using the tray menu. Next, copy the SoftRightClick folder into Program Files. Finally, open the SoftRightClick folder and double-click SoftRightClick.exe.

NOTE: SoftRightClick.icl must remain in the same folder as SoftRightClick.exe for the custom tray icons to work. Simlarly, the file circle.gif must be in the same folder as SoftRightClick.exe for the "impending right-click" indicator to appear.

## Tray icon and menu

When SoftRightClick is launched, a green R icon appears in the tray. (The leg of the R is a mouse pointer.) Currently the tray icon's context menu can be used to enable or disable SoftRightClick's functionality, to set options, or to exit the program. Tapping or double-tapping the tray icon toggles SoftRightClick's enabled/disabled state. You can right-click (or tap-and-hold if SoftRightClick is enabled!) to pop up a context menu allowing you to enable or disable the program, set a few options, force a click mode, or exit SoftRightClick entirely. The options are:

* Left/Right/Middle/Hover. Special click modes. Left forces the next tap to be taken as a left click, Right forces the next tap to be taken as a right click, etc. See SPECIAL CLICK MODES below.

* Exit. Exits SoftRightClick.

* Options. Displays options dialog (see OPTIONS DIALOG following).

* Unhook. Entirely unhooks SoftRightClick from detecting taps. Double-click the tray icon to re-enable it. While SoftRightClick is unhooked, not only will the tap-and-hold feature be disabled, but also tray icon gestures (see PEN GESTURES below). This is because SoftRightClick needs to be able to trap mouse clicks to detect clicks on its own tray icon. Use this feature if you encounter any program that won't respond to the pen or mouse while SoftRightClick is running. However, see the SPECIAL NOTE below if you use ZoneAlarm.

* Enable/Disable. Enables or disables the tap-and-hold feature. When off, you can only left-click with the stylus. Double-clicking the tray icon is the same as selecting this menu item.

The tray icon changes color to indicate SoftRightClick's status. The colors are:

* Green: Fully active
* Red: Disabled.
* Blue: Special click mode (see SPECIAL CLICK MODES below).
* Gray: Unhooked.

## Options dialog

The available options in the Options dialog are:

* Tap-and-hold timeout in milliseconds. 
This is the timeout for right-clicking by holding down the stylus while keeping it in the same spot.
 Default is 750ms (3/4 sec).

* Drag-and-hold timeout in milliseconds. If enabled, this is the timeout for right-clicking by holding the stylus down in one place after you have dragged it (for example when selecting text).
 Default is 1500ms (1.5 sec).

* Accuracy. Determines the amount of stylus movement that is considered to be "in one place" (slop). Precise is 2 pixels, Middlin' is 4, Sloppy is 6. If you move the stylus more than this distance while holding it down, SoftRightClick believes you have begun a drag and uses the drag-and-hold timeout. Set this to the lowest value that works for your level of dexterity. Default is Middlin'.

* Allow drag-and-hold outside the window. If checked, SoftRightClick will still trigger a right-click (after the drag-and-hold timeout) after you have dragged outside the window. If not checked, the timeout becomes very long (1000 sec) if you drag outside the window, which is basically the same as not having a timeout at all. This is because right-clicking while you're dragging files from one window to another will cause you to "drop" the files, which can be an inconvenience if you've just paused to make sure of what you're doing before releasing the stylus. Default is off.

* Pass through initial mousedown immediately. If checked, SoftRightClick will pass through the initial mousedown as soon as you touch the stylus to the screen. If unchecked, SRC waits for you to drag outside the slop area (see Accuracy setting) before actually passing through the initial mousedown. Leaving this off will allow you to tap-and-hold on selected text without de-selecting it. Default is off.

* Show indicator before right-clicking. If checked, a red circle will appear around the pointer when you've been holding the stylus down for half the tap-and-hold (or drag-and-hold) timeout. (This has some cosmetic issues sometimes, particularly if drag-and-hold is enabled. There's nothing I can do about this and it doesn't affect functionality.)

* Load at startup. If checked, adds a registry entry to automatically load SoftRightClick when you log in to Windows. Your spyware/virus software may notify you that something has happened or ask you whether to allow it -- say yes.

* Enabled by default. If checked, SoftRightClick will be active immediately after you (or Windows) launches it. Otherwise you have to click the tray icon to activate it the first time.

Changes to the options are saved in the registry under HKCU\Software\SoftRightClick.

## Pen gestures

The tray icon supports pen gestures. To invoke a gesture, start with the stylus on the SoftRightClick icon and then drag off the icon. The gestures are as follows:

* Tap tray icon: Toggle SoftRightClick on/off.

* Hold tray icon: SoftRightClick tray menu. (See TRAY MENU AND ICON above.)

* Drag up or drag down: SoftRightClick tray menu. (See TRAY MENU AND ICON above.)

* Drag left: Force next tap to be left-click. (See below.)

* Drag right: Force next tap to be right-click. (See below.)

* Drag diagonally (up or down) and to the left: Force next tap to be middle-click. (See below.)

* Drag diagonally (up or down) and to the right: Force next tap to move the cursor only, i.e., hover mode. (See below.)

The gestures for the special click modes are disabled when SoftRightClick is disabled. All gestures are disabled when SoftRightClick is unhooked.

## Special click modes

The special click modes Left, Right, Middle, and Hover can be chosen from SoftRightClick's tray menu or by means of gestures. (Note that these modes can be chosen even when the tray icon is red rather than green!) When you choose one of these modes, the tray icon turns blue for three seconds. If you don't tap during this three second window, the special click mode expires and the tray icon will return to its normal appearance. The tap-and-hold functionality is disabled during the special click modes -- if you have chosen a left click, you get a left click and nothing but, ever. Using the special click modes you can do things like middle-click a link in Firefox to open it in a new tab, or right-drag an icon to the desktop to create a shortcut.

## Scroll bars and other special controls

A word about scroll bars and a few other types of controls -- right-clicking on these controls is not normally something you'd want to do. SoftRightClick tries to recognize when you're holding down on a control that it would be counterintuitive to right-click and only left-click on it. However, it's not by any means perfect and it will miss some controls. It might be better to get in the habit of performing discrete taps and/or dragging these kinds of controls, as it will do what you want more often.

## Special note

If you use ZoneAlarm, you will find that you cannot control it with SoftRightClick running. The firewall works fine but clicks in ZoneAlarm windows are ignored. This is a security feature in ZoneAlarm to prevent malicious programs from disabling your firewall. (ZoneAlarm by default ignores virtual clicks, i.e. clicks not generated by a real physical mouse button. SoftRightClick intercepts all physical clicks and sends only virtual clicks, so ZoneAlarm will never see a physical click while SoftRightClick is running.) To resolve thi issue, you have two choices:

* Unhook or exit SoftRightClick when you want to use ZoneAlarm dialogs (use SoftRightClick's tray menu)
* Disable this security feature of ZoneAlarm in ZoneAlarm's preferences (uncheck "Protect the ZoneAlarm client")

The latter should have minimal impact on your security. Since this setting is turned on by default in ZoneAlarm, I would imagine that malware that tries to control ZoneAlarm by manipulating its UI is probably quite rare. I've certainly never heard of any.

Another option is to uninstall ZoneAlarm. Windows' built-in firewall, believe it or not, works perfectly well and is adequate for most users. (ZoneAlarm does have more features, and if these are important to you, then by all means use ZoneAlarm, but don't just install it out of habit or because you heard it was important.)

## Credit where due

SoftRightClick was developed with AutoHotKey, a pretty kick-ass scripting utility that happens to be free to download and use. It includes a utility to turn your scripts into EXEs complete with taskbar icons. One of the sample scripts is a script is a mouse gesture interpreter!

More about AutoHotkey here: http://www.autohotkey.com/

# Copyright (not)

SoftRightClick is free. By which I mean not merely the wimpy version of "free" in which I give you the code but tell you what you can and can't do with it, but fully in the public domain -- the old-school version of free!  I hereby explicitly disclaim all copyright in and liability for this utility. (That means if it causes any problems for you, I'm not responsible.) Source code for the script is included.

# Version history

- v1.0: Initial release. Pretty sad by modern standards, really.

- v1.1: Added ability to invoke right-click at the end of a drag 
	(allows you to pop up contextual menus after making a text selection)
      Reduced slop factor to 5 pixels from 10
      Added ability to enable/disable/exit from tray icon.
	(double-tap tray icon is a shortcut for enable/disable)
- v1.2: You can now click-and-hold on selected text without deselecting it.
      The click-and-hold timeout is doubled when you began by dragging.
      Standard click-and-hold timeout is now 750ms (3/4 sec)
- v1.3: If you drag outside the current window, the timeout becomes really long
	(100 sec to be exact -- so it doesn't drop what you're dragging)
- v1.4: Added preferences for tap-and-hold and drag-and-hold delays, precision,
	and option to allow drag-and-hold outside a window; custom tray icons,
  Made minor changes to tracking to help it work better with RitePen
- v1.5: Fixed problem right-clicking on wireless network tray icon (and others)
- v1.6: Reduced CPU usage significantly. Added passthrough mode. Fixed bug in
	Accuracy setting. Put settings into HKCU where I meant to put 'em in
	the first place. (Fallback to HKLM where they were put erroneously.)
- v1.7: Fixed the dodgy behavior with RitePen once and for all! You no longer
	need to use passthrough mode to get RitePen to work correctly.  Now
	recognize some scroll bars and other controls and automatically pass
	through for them (and disable the right-click).
- v1.8: Corner shortcuts added. Ability to launch at startup and to determine
	initial state at launch added. Added option to disable drag-and-hold.
	The second click of a double-click is now passed through immediately
	and this is considered a drag action for purposes of drag-and-click.
	Can now drag on context menus (left click is sent upon release if 
	you drag after you've invoked a right-click by holding). Sorta detect
	scrollbars in Opera/Mozilla (actually we just assume the right 20px
	of any pane is a scrollbar, which is cheating and means you simply
	can't invoke right-click through tap-and-hold in that zone).
- v1.9: Updated to newer version of AUtoHotKey to hopefully fix the "you have
	hit a hotkey X times in Y ms" errors (let me know if you still get
	them). Added indicator for impending right-click at half the hold
	timeout. Options window appears in lower right corner of screen,
	closer to the tray icon.  Added tray icon gestures; removed corner
	clicks. Added special click modes to tray menu.  Added Unhook
	command (which does what Disable used to do).  Improved Readme.
- v1.9A: Fixes for display of tray icon and impending right-click indicator and
	for double-clicking when pass-through mode is enabled in Options.
- v1.9B: Fix for "too many hotkeys" errors once and for all (I hope).  Gray
	tray icon for Unhook mode. Added short delay when tapping so
	programs like Google Earth can see the tap. Fixed error message
	when unhooking in disabled mode.  More accurate detection of taps
	on our tray icon (sometimes it would think the neighboring icon was
	ours). Updated version of AutoHotkey engine.

Other ideas? Feedback? Tell me -- see e-mail address under CONTACT INFO above.
