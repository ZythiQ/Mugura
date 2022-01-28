#SingleInstance Force
#Include get_URL.ahk
#NoTrayIcon
#NoEnv

SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
SetBatchLines, -1
SetWinDelay, -1
SendMode Input

; Initializing Variables:

fileRead, excludeCase, resources\titleCaseExclude.txt

chromePath := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
wraps := {40:"()", 60:"<>", 91:"[]", 95:"____", 123:"{}"}
smartQuotes := False
reSelect := True
precise := True

; Hotkeys:

^+c::getPath()
^#c::getActivePath()
^+g::searchSel()
^+z::swapSel()
!c::countSel()

^+w::wrapSel("select")
^w::wrapSel("repeat")
!w::wrapSel("remove")

; !p::formatSel("pasteTest")
!u::formatSel("upperCase")
!l::formatSel("lowerCase")
!f::formatSel("firstCase")
^!f::formatSel("firstOnly")
!s::formatSel("sentnCase")
!t::formatSel("titleCase")
!q::mPress(func("formatSel").bind("fixQuotes"), func("formatSel").bind("fixQuotes", 1))
!n::mPress(func("formatSel").bind("fixNumber"), func("formatSel").bind("fixNumber", 1))

^{::wrapSel(123)
$^[::wrapSel(91)
^(::wrapSel(40)
^%::wrapSel(37)
^_::wrapSel(95)

^+'::mPress(func("wrapSel").bind(34), func("wrapSel").bind(257))
^'::mPress(func("wrapSel").bind(39), func("wrapSel").bind(258))

; ^"::wrapSel(34)
; ^'::wrapSel(39)
; ^!"::wrapSel(257)
; ^!'::wrapSel(258)

; Personal Hotkeys:

^XButton2::sendInput #{Tab}
^XButton1::sendInput !{Esc}
!Left::sendInput ^[
!Right::sendInput ^]
#c::checkToConnect("RIT")

^+!Home::reload
^+!Ins::suspend
^+!End::ExitApp
^+!Del::endProcs()
^+!e::edit

; Mini Hotkeys:

^+k::
if (isURL(clipboard)) {
	BlockInput, On
	send ^k
	sleep 100
	send ^v{enter}
	BlockInput, Off
}
return

; Clipboard Functions:

formatSel(type, modifier=0) {
	global excludeCase
	if (copySel()) {
		switch (type) {
			case "upperCase": txt := format("{:U}", clipboard)
			case "lowerCase": txt := format("{:L}", clipboard)
			case "firstCase": txt := regexReplace(clipboard, "m)((^|\W)\w)", "$u1")
			case "firstOnly": txt := regexReplace(clipboard, "m)^(\w)", "$u1")
			case "sentnCase": txt := regexReplace(clipboard, "m)(((^[“‘""']?|([.?!:]+\s+))[a-z])| i | i')", "$u1")

			case "titleCase":
			txt := regexReplace(clipboard, "(([.\s-]+[a-z])| i | i')", "$u1")
				loop, parse, excludeCase, `n, `r
					txt := regexReplace(txt, "i)\b" . A_loopField . "\b", A_loopField)
				txt := regexReplace(txt, "m)((^[“‘""']?|(:\s+))[a-z])", "$u1")

			case "fixNumber":
				if (clipboard ~= "^[0-9,.]*$") {
					txt := regexReplace(clipboard, ",")
					txt := (txt ~= "\.") ? RTrim(RTrim(modifier ? Round(txt, 6) : txt,"0"),".") : modifier ? regexReplace(txt, "\G\d+?(?=(\d{3})+(?:\D|$))", "$0,") : txt
				}

			case "fixQuotes":
                if (clipboard ~= "^[""“‘'](.*)[""'’”]$") {
                    txt := regexReplace(clipboard, """(.*)""", "“$1”")
                    txt := regexReplace(txt, "(?<=\s|[“‘'])[""“'](?!$)", "‘")
                    txt := regexReplace(txt, "(?<!^|\d)[""”'](?!$)", "’")
                    if (!modifier) {
                        txt := regexReplace(txt, "[“”]", """")
                        txt := regexReplace(txt, "[‘’]", "'")
                    }
                } else return

			default: txt := clipboard
		}
		pasteSel(txt)
	} else clipboard := tmp
}

wrapSel(type){
    global wraps, key
    if (copySel()){
        switch type {
            case "select":
				; Determines which symbol to use in the text wrap:
                pushToast("TextWrap Enabled:", "Select a wrap.", 0x16, "printer")
                input, key, L1 T3, {lControl}{lAlt}{lWin}{Esc}{Tab}{BS}
                key := ord(key)
                gui, Destroy
                if (errorLevel <> "Max")
                    return
            case "remove":
				; Clears all surrounding symbols from the selection:
				clipboard := trim(clipboard, "<({[@#$^&*\/+-=~``'""“”‘’_%|]})>")
				pasteSel(clipboard)
				return
			case "repeat":
			default: key := type
        }
		; Assigns the left/right wrap if it exists, otherwise uses the input symbol:
        lKey := (wraps[key]) ? subStr(wraps[Key], 1, strLen(wraps[Key])/2) : chr(key)
        rKey := (wraps[Key]) ? subStr(wraps[key], (strLen(wraps[key])/2)+1) : lKey

		; Fix quotes to prefered version:
		if (key ~= "257|258") {
			lKey := (key == 257) ? "“" : "‘"
			rKey := (key == 257) ? "”" : "’"
		}
        pasteSel(lKey . clipboard . rKey)
    } else clipboard := tmp
}

searchSel() {
	global tmp, chromePath
	if (copySel()) {
		if (IsURL(clipboard) or FileExist(clipboard))
			run %clipboard%
		else
			run %chromePath% -incognito "http://www.google.com/search?q=%clipboard%"
	}  clipboard := tmp
}

swapSel() {
	tmp := clipboard
	if (selected := copySel()) {
		pasteSel(tmp)
		clipboard := selected
	} else clipboard := tmp
}

countSel() {
	tmp := clipboard
	if (selected := copySel()) {
		regexReplace(clipboard, ".*?[a-zA-Z-'’‘]+" ,, alphaCount, -1, 1)
		regexReplace(clipboard, ".*?[\w-'’‘]+" ,, alphaNumCount, -1, 1)
		toolTip % alphaCount " words`n" alphaNumCount " w/ numbers`n" strLen(clipboard) " characters`n" strLen(StrReplace(clipboard, " ")) " w/o spaces"
		setTimer, RemoveToolTip, -1500
	} else clipboard := tmp
}

; Copy-Paste Management:

copySel() {
	global tmp
	tmp := clipboardAll
	clipboard := ""
	send ^c
	clipWait, 0.1
	clipboard := regexReplace(clipboard, "\s+$")
	if clipboard is not space
		return clipboard
	sleep 25
	clipboard := tmp
}

pasteSel(txt) {
	global tmp, precise, reSelect
	; Initialize and paste the clipboard:
	clipboard := txt
	send ^v
	sleep 25
	winGetTitle, winTitle, A

	; Docs adds a newline if the paste contains one... backspace to remove it.
	if (txt ~= "\R" and winTitle ~= "Google (Docs|Slides)")
		send {BS}

	if (reSelect) {
		if (!precise and winTitle ~= "(Google (Docs|Slides)|Visual Studio Code|- Word)") {
			; "Ctrl + shift + {left}" method setup:
			if (winTitle ~= "Google Docs")
				txt := regexReplace(txt, "\R|\t|[\w–—‘’']+|[^\w\s]+", "+")
			else if (winTitle ~= "- Word")
				txt := regexReplace(txt, "\R|\t|[a-zA-Z0-9‘’']+|[^\w\s]+", "+")
			else if (winTitle ~= "Visual Studio Code")
				txt := regexReplace(txt, "\t+|(?<=\n)\R|([^\w\s–—‘’]|'){2,}|[\d\w–—‘’]+\W|[\w–—‘’]+", "+")

			; Send for speed methods:
			send  % "{control down}{shift down}{left "strLen(regexReplace(txt, "\s"))"}{control up}{shift up}"

		; Slow but precise "Shift + {left}" method:
		} else	send % "+{left "strLen(regexReplace(txt, "\R", "+"))"}"
	}
	; Refresh the clipboard:
	sleep 25
	clipboard := tmp
}

; URL Retrieval Functions:

getPath(returnsURL=False) {
	global ModernBrowsers, LegacyBrowsers
	WinGetClass, sClass, A

	if sClass in % ModernBrowsers
		sURL := getBrowserURL_ACC(sClass)
	else if sClass in % LegacyBrowsers
		sURL := getBrowserURL_DDE(sClass)
	else if sClass ~= "(Cabinet|Explore)WClass"
		sURL := getBrowserURL_FV()
	else return ; Returns an empty string if unsupported and/or not a browser.

    if (sURL <> "") {
		if (returnsURL)
			return sURL
        clipboard := sURL
		soundPlay, %A_WinDir%\Media\Windows Balloon.wav
		return
	} else if sClass in % ModernBrowsers "," LegacyBrowsers
        msgBox, % "The URL couldn't be determined (" sClass ")"
    else
        msgBox, % "Unsupported and/or not a browser (" sClass ")"
    return
}

getBrowserURL_FV() {
    winGetClass, winClass, % "ahk_id" . hWnd := winExist("A")
	; Pull data from folder bar in File Explorer:
    for window in ComObjCreate("Shell.Application").Windows
        if (hWnd = window.HWND) && (oShellFolderView := window.Document)
            break
    for item in oShellFolderView.SelectedItems
        result .= (result = "" ? "" : "`n") . item.path

    if !result
        result := oShellFolderView.Folder.Self.Path
    return result
}

getActivePath(returnsURL=False) {
	; Modified from Jeeswg: https://www.autohotkey.com/boards/viewtopic.php?f=5&t=38680&p=177407#p177407
	WinGet, vPID, PID, A
	oWMI := ComObjGet("winmgmts:")
	oQueryEnum := oWMI.ExecQuery("Select * from Win32_Process where ProcessId=" vPID)._NewEnum()
	if oQueryEnum[oProcess]
		sURL := oProcess.ExecutablePath
	oWMI := oQueryEnum := oProcess := ""
	if (returnsURL)
		return sURL
	clipboard := sURL
	soundPlay, %A_WinDir%\Media\Windows Balloon.wav
}

; Notification Functions:

pushToast(title, toast, hexCode, iconName="brackets") {
	; Initialize the toast:
	gui, Add, Picture, w39 h-1 y30 x20, %A_ScriptDir%\resources\%iconName%.ico
	gui +alwaysOnTop -caption +lastFound +owner -sysMenu
	gui, Font, cFFFFFF s11, Segoe UI
	gui, Add, Text, x79 y20, % title
	gui, Add, Text, xp y+4 cB3B3B3, % toast
	gui, Color, 242424
	gui, Margin,, 15
	; Estimating size of toast body to properly locate/animate it on screen:
	gui, Show, Hide
	guiID := WinExist()
	winGetPos,,,, guiHeight, ahk_id %guiID%
	sysGet, Workspace, MonitorWorkArea
	newX := WorkSpaceRight-381
	newY := WorkspaceBottom-guiHeight-12
	; Animate or not to animate the toast:
	if (!hexCode) {
		gui, Show, x%newX% y%newY% w365
		return 
	}
	gui, Show, Hide x%newX% y%newY% w365
	DllCall("AnimateWindow","UInt",guiID,"Int",100,"UInt",hexCode)
}

RemoveToolTip:
ToolTip
return

; Script Control:

endProcs() {
	winGet, list, list, ahk_class AutoHotkey
	loop %list%
	{ 
		winGet, PID, PID, % "ahk_id "list%A_Index% 
		if (PID <> DllCall("GetCurrentProcessId")) {
			postMessage, 0x111,65405, 0,, % "ahk_id "list%A_Index%
			soundPlay, %A_WinDir%\Media\Windows Balloon.wav
		}
	}
}

; Miscellaneous:

mPress(pressHandlers*) {
	; Modified from: http://autohotkey.com/boards/viewtopic.php?t=40161
	recurse:
	keyPresses += 1
	strippedHotkey := stripHotkey(A_ThisHotkey)
	keyWait, %strippedHotkey%
	keyWait, %strippedHotkey%, D T.12 ; Wait for same KeyDown or 0.12 seconds to elapse.
	if (!ErrorLevel)
		goto recurse

	; Ensuring that the handler is a function object, and if not making it one or returning nothing:
	hf := pressHandlers[keyPresses]
	if (!IsObject(hf))
		hf := Func(hf)
	return hf ? hf.Call() : ""
}

stripHotkey(hk) {
	; From: https://autohotkey.com/board/topic/32973-func-waitthishotkey/
	regExMatch(hk, "i)(?:[~#!<>\*\+\^\$]*([^ ]+)( UP)?)$", key)
	return key1, ErrorLevel := (key2 ? "Down" : "Up")
}

checkToConnect(adapter, nType = "WLAN", url = "http://google.com") {
	if (!ping()) {
		runwait, % comspec  " /c Netsh " nType " connect name=" adapter
		soundPlay, %A_WinDir%\Media\Windows Balloon.wav
	} else
		soundPlay, %A_WinDir%\Media\Windows Background.wav
}

ping(host="8.8.8.8") { ; default pings Google DNS
	colPings := ComObjGet("winmgmts:").ExecQuery("Select * From Win32_PingStatus where Address = '" host "'")._NewEnum
	while colPings[objStatus]
		return oS := (objStatus.StatusCode = "") || (objStatus.StatusCode != 0) ? 0 : 1
}