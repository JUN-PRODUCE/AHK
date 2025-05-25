;ホットスリング
:*:mmm::MsgBox,,,%%
:*:ttt::ToolTip, %%
:*:rrr::Return
:*R:nnn::``n
:*:/22::""{left 1}
:*:/55::%%{left 1}
:*:/88::(){left 1}

;選択範囲をgoogle検索　Ctr+Shift+マウス中ボタン
^+MButton::
	Clipboard := ""
	Send, ^c
	Sleep, 30
	GoSub, Chrome_Search_fork
Return

;選択範囲をAHK検索　Ctr+Alt+Shift+マウス中ボタン
^+!MButton::
	Clipboard := ""
	Send, ^c
	Sleep, 30
	Run, https://sites.google.com/site/autohotkeyjp/system/app/pages/search?scope=search-site&q=%Clipboard%
	WinActivate, ahk_exe chrome.exe
Return

;選択範囲をWizFile検索　Ctr+Alt+マウス中ボタン
^!MButton::
	SetKeyDelay, -1
	Critical, On
	BlockInput, On
	Clipboard := ""
	Send, ^c
	Sleep, 30
	WinActivate, ahk_class TfrmWizFileMain ahk_exe WizFile64.exe
	PostMessage, 0x0111, 2,,,A ;クリア(&L)	F6
	Sleep, 30
	Send, ^v
	IME_SET(1) ;IME ON
	BlockInput, Off
	Critical, Off
Return

;AHK KeyHistory Alt+Ctr+Shft+F10
^+#F10::KeyHistory

;AHK緊急停止 Ctrl+Shift+Alt+Escape
^+#Escape::
	suspend
	pause, toggle, 1
	if (A_IsSuspended = 1) { ;サスペンド中
		my_tooltip_function("● AHKスタンバイ", 950)
		SoundPlay("standby.mp3")
		Return
	} else if (A_IsSuspended = 0) { ;再開
		my_tooltip_function("● AHKスタート", 950)
		SoundPlay("all_system_ready.mp3")
	}
Return

;保存成功tooltip
~^s::
	if (WinActive("ahk_exe emeditor.exe") || WinActive("- Google Chrome")) {
		send, ^s
		my_tooltip_function("● 保存成功", 950)
	Return
	}
	else if (WinActive("_AutoHotkey - Visual Studio Code")) {
		send, ^s
		my_tooltip_function("● ＡＨＫ 更新完了！", 950)
		SoundPlay("chocobo.mp3")
		Reload
	Return
	}
Return

;アプリのEXEフォルダーを開く in Folder（SmartSystemMenu経由）
^+#E::
	PostMessage, 0x0112, 18435,,,A
	my_tooltip_function("● Explorerで開く", 950)
Return


; ------------------------------------------------
; ウィンドウ操作
; ------------------------------------------------

;常に手前に表示（SmartSystemMenu経由）
#NumpadAdd::
	toggle := !toggle
	While (toggle)
	{
		PostMessage, 0x0112, 18275,,,A
		my_tooltip_function("● 最前面", 950)
		Return
	}
	PostMessage, 0x0112, 18275,,,A
	my_tooltip_function("最前面 解除", 950)
Return


if (A_ComputerName = "SYCOM") {
; TVモニタ左上
^NumpadDiv::
	if (WinActive("ahk_exe FreeCommander.exe") || WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, -930, -804, 1050, 774
	MouseMove, 260, 352, 0
	WinActivate, ahk_id %hwnd%
Return

; TVモニタ右上
^NumpadSub::
	if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, -735, -799, 1095, 767
	MouseMove, 260, 352, 0
	WinActivate, ahk_id %hwnd%
Return

; 中央モニタ真ん中
^Numpad5::
	if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	else if (WinActive("ahk_exe cmd.exe") || WinActive("ahk_exe tabby.exe"))
	{
		WinMove, ahk_id %hwnd%,, 0, 0, 753, 1040
		MouseMove, 600, 495, 0
		WinActivate, ahk_id %hwnd%
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, 435, 12, 1177, 1031
	MouseMove, 600, 495, 0
	WinActivate, ahk_id %hwnd%
Return

; 中央モニタ全画面
^Numpad6::
	if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, 0, 0
	MouseMove, 600, 495, 0
	WinMaximize, A
	WinActivate, ahk_id %hwnd%
Return

; 上モニタ左
^Numpad7::
	if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, 360, -1086, 1584, 1047
	MouseMove, 950, 500, 0
	WinActivate, ahk_id %hwnd%
Return

; 上モニタ全画面
^Numpad8::
	if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, 360, -1085, 1934, 1052
	MouseMove, 950, 500, 0
	; WinMaximize, A
	WinActivate, ahk_id %hwnd%
Return

; 上モニタ右
^Numpad9::
	if (WinActive("ahk_exe scrcpy.exe"))
	{
		MouseGetPos,,, hwnd
		WinRestore, ahk_id %hwnd%
		WinMove, ahk_id %hwnd%,, 1320, -1093, 570, 1060
		MouseMove, 465, 472, 0
		WinActivate, ahk_id %hwnd%
		Return
	}
	else if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, 1329, -1086, 966, 1047
	MouseMove, 950, 500, 0
	WinActivate, ahk_id %hwnd%
Return

; 縦モニタ上
^Numpad4::
	if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, -909, 0, 914, 1200
	MouseMove, 465, 472, 0
	WinActivate, ahk_id %hwnd%
Return

; 縦モニタ下
^Numpad1::
	if (WinActive("ahk_exe scrcpy.exe"))
	{
		MouseGetPos,,, hwnd
		WinRestore, ahk_id %hwnd%
		WinMove, ahk_id %hwnd%,, -663, 4, 666, 1399
		MouseMove, 465, 472, 0
		WinActivate, ahk_id %hwnd%
		Return
	}
	else if (WinActive("ahk_exe FreeCommander.exe")) || (WinActive("ahk_class Shell_SecondaryTrayWnd"))
	{
		Return
	}
	MouseGetPos,,, hwnd
	WinRestore, ahk_id %hwnd%
	WinMove, ahk_id %hwnd%,, -902, 44, 900, 1363
	MouseMove, 465, 472, 0
	WinActivate, ahk_id %hwnd%
Return
} ;if (A_ComputerName = "SYCOM")

;ウィンドウ最大化操作
#Esc::
MouseGetPos,,, hwnd
WinGet, var_winmax, MinMax, ahk_id %hwnd%
If var_winmax = 1
	{
		PostMessage, 0x0112, 0xF120,,, ahk_id %hwnd%
		; WinRestore, A
		Return
	}
If var_winmax = 0
	{
		PostMessage, 0x0112, 0xF030,,, ahk_id %hwnd%
		; WinMaximize, A
		Return
	}
Return


; ------------------------------------------------
; 片手操作
; ------------------------------------------------

; 片手矢印 左wasd 右ijkl 無変換キーの押下中
sc07B & w::
sc07B & i::
	my_tooltip_function_Caret("↑", 150)
	Send, {Blind}{Up}
	Caret_IME()
Return

sc07B & s::
sc07B & k::
	my_tooltip_function_Caret("↓", 150)
	Send, {Blind}{Down}
	Caret_IME()
Return

sc07B & a::
sc07B & j::
	my_tooltip_function_Caret("←", 150)
	Send, {Blind}{Left}
	Caret_IME()
Return

sc07B & d::
sc07B & l::
	my_tooltip_function_Caret("→", 150)
	Send, {Blind}{Right}
	Caret_IME()
Return

;片手クリック
sc07B & Space::
	my_tooltip_function_Caret("Click", 150)
	SendInput, {Click}
Return


;片手Delete
^Q::
	SendInput, {Delete}
Return

;片手Backspace
^+Q::
	SendInput, {Backspace}
Return


; ------------------------------------------------
; テキスト処理
; ------------------------------------------------

; ()
sc07B & 1::
	my_tooltip_function_Caret("( )", 750)
	GoSub, bracket8
Return

; ""
sc07B & 2::
	my_tooltip_function_Caret(""" """, 750)
	GoSub, bracket3
Return

; %%
sc07B & 3::
	my_tooltip_function_Caret("% %", 750)
	GoSub, bracket9
Return

; []
sc07B & 4::
	my_tooltip_function_Caret("[ ]", 750)
	GoSub, bracket7
Return


; ------------------------------------------------
;
; ------------------------------------------------


;無変換+スクロールx10
~sc07B & WheelDown::
	Send, {Blind}{WheelDown 10}
	IME_SET(0)
return

~sc07B & WheelUp::
	Send, {Blind}{WheelUp 10}
	IME_SET(0)
return



;キー無効
#F1::Return
;#G::Return
; ^Esc::Return
!Esc::Return
; #Esc::Return
#F13::Return
; #NumpadAdd::Return
Insert::Return

; NumLockキーを＝
NumLock::=
