;KeyPressed ver 1.0
;
; F13::
; If KeyPressed("F13")
; {
; ;２回押下
;    Send, {F13 2}
;    Return
; }
; Else
; {
; ;１回押下
;    GoSub, Chrome_Translate
;    return
; }
; Return

;一定時間内にそのキーが押されたかどうかを返す
;押されれば1,押されなければ0を返す
;デフォルトは300ミリ秒
;
;押されない時は待ち時間分動作が止まるので
;ダブルクリックのようなことに使う場合、
;シングルクリックしかしなかった時に動作が遅くなる
;シングルクリック動作をキャンセルしなくてよく、押した瞬間さっさと
;動いて欲しければDoubleActionを使う
KeyPressed(key, waitMs = 180)
{
	ListLines, Off
	;stateは早めに取ったほうがいいのかな
	;とりこぼしたためしはないけど
	GetKeyState state, %key%, P

	start = %A_TickCount%

	if state = U
	{
		;UだったらDのあとのUを待つ
		;Uで起動するホットキーから使われてると思うので
		;DでとめたらそのあとのUでまたキーが起動しかねない
		states = D/U
	}
	else
	{
		;DだったらUのあとDになるのを待つ
		states = U/D
	}
	StringSplit stateArray,states,/
	i = 1

	;キーをとるのでクリティカルな処理
	Critical On
	Loop
	{
		GetKeyState state2, %key%, P

		if(state2 = stateArray%i%)
		{
			i++
		}
		if(stateArray0 + 1 = i)
		{
			result = 1
			break
		}

		If A_TickCount - start > waitMS
		{
			result = 0
			break
		}
	}
	Critical Off

	;どういう理屈かしらないが、
	;スリープをいれないと誤動作する
	Sleep 5
	ListLines, On
	return result
}

;----------------------------------------------------------

; my_tooltip_function("テキスト", 500)
my_tooltip_function(pStr, pDelay) {
	ToolTip, %pStr% ;表示テキスト内容。””で囲む。
	SetTimer, remove_tooltip, -%pDelay%
}

remove_tooltip:
	ToolTip
Return

remove_tooltip_all:
	SetTimer, remove_tooltip, Off
	Loop, 20
		ToolTip, , , , % A_Index
Return

;----------------------------------------------------------
; my_tooltip_function_Caret("テキスト", 500)
my_tooltip_function_Caret(pStr, pDelay) {
	vCaretX := A_CaretX + 15
	vCaretY := A_CaretY + 15
	CoordMode, Caret, Window
	ToolTip, %pStr%, %vCaretX%, %vCaretY%
	SetTimer, remove_tooltip, -%pDelay%
}

;----------------------------------------------------------

;アクションセンターを開いてBluetoothスイッチをクリック
SwitchBluetooth() {
	Send, #a
	Sleep, 100
	Send, +{Tab}
  Sleep, 100
	Send, {space}
	Sleep, 50
	Send, #a
	;別Ver
;	Run, bthprops.cpl
;	Sleep, 50
;	Send, {Tab}
;	Sleep, 10
;	Send, {Space}
;	Sleep, 50
;	Send, !F4
;	WinClose, ahk_exe ApplicationFrameHost.exe
}

;----------------------------------------------------------
;プロセス優先度 高
;Process_High("001.exe/002.exe/003.exe")
Process_High(Process_p1){ ;既にそのプロセスが存在している場合
	Loop,parse,Process_p1,/
	{
		Process,Exist,%A_LoopField%
		if ( NewPID:=ErrorLevel )
			Process,Priority,%NewPID%,High
	}
	Notify("完了 Process_High", "", -1, "Style=Huge")
}

;プロセス優先度 低
;Process_Low("001.exe/002.exe/003.exe")
Process_Low(Process_p2){ ;既にそのプロセスが存在している場合
	Loop,parse,Process_p2,/
	{
		Process,Exist,%A_LoopField%
		if ( NewPID:=ErrorLevel )
			Process,Priority,%NewPID%,Low
	}
	Notify("完了 Process_Low", "", -1, "Style=Huge")
}
;----------------------------------------------------------
;指定時間でEXE自動終了(msec指定)
;Run, cmd.exe,,, VPID
;IdleLimit_AppClose(5000)

IdleLimit_AppClose(timer) {
	Global
	idleLimit:=timer
	SetTimer, CloseOnIdle, % timer+150
}

CloseOnIdle:
	if (A_TimeIdle>=idleLimit)
	{
		WinClose, ahk_pid %VPID%
		SetTimer,CloseOnIdle, Off
	}
	else
	{
		SetTimer,CloseOnIdle, % idleLimit-A_TimeIdle+150
	}
return

;----------------------------------------------------------
;プロセスのコマンドラインを取得
; 1::
; GetFilePath()
; ToolTip, % vGetFilePath_Full "`n`n" vGetFilePath_App "`n`n" vGetFilePath_File
; Return

GetFilePath() {
	global vGetFilePath_Full ;全コマンドライン
	global vGetFilePath_App ;アプリパス
	global vGetFilePath_File ;ファイルパス
	WinGet, PID, PID, A
	WinGet, vGetFilePath_App, ProcessPath, A
	obj := GetCommandLine(PID, true, true)
	vGetFilePath_Full = % obj.cmd
	vGetFilePath_File := RegexReplace(vGetFilePath_Full, "\x22.*\x22\s|\x22", "") ;アプリパス削除
}

GetCommandLine(PID, SetDebugPrivilege := false, GetImagePath := false) {
	static SetDebug := 0, PROCESS_QUERY_INFORMATION := 0x400, PROCESS_VM_READ := 0x10, STATUS_SUCCESS := 0

	if (SetDebugPrivilege && !SetDebug) {
		if !res := SeDebugPrivilege()
			SetDebug := 1
		else {
			MsgBox, 4, エラー SeDebugPrivilege(), 特権の設定に失敗しました。`nError %res%nContinue?
			IfMsgBox, No
			Return
		}
	}
	hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION|PROCESS_VM_READ, Int, 0, UInt, PID, Ptr)
	(A_Is64bitOS && DllCall("IsWow64Process", Ptr, hProc, UIntP, IsWow64))
	if (!A_Is64bitOS || IsWow64)
		PtrSize := 4, PtrType := "UInt", pPtr := "UIntP", offsetCMD := 0x40
	else
		PtrSize := 8, PtrType := "Int64", pPtr := "Int64P", offsetCMD := 0x70

	hModule := DllCall("GetModuleHandle", "str", "Ntdll", Ptr)
	if (A_PtrSize < PtrSize) { ; スクリプト 32, ターゲットプロセス 64
		if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64QueryInformationProcess64", Ptr)
			failed := "NtWow64QueryInformationProcess64"
		if !ReadProcessMemory := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64ReadVirtualMemory64", Ptr)
			failed := "NtWow64ReadVirtualMemory64"
		info := 0, szPBI := 48, offsetPEB := 8
	}
	else {
		if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtQueryInformationProcess", Ptr)
			failed := "NtQueryInformationProcess"
		ReadProcessMemory := "ReadProcessMemory"
		if (A_PtrSize > PtrSize) ; スクリプト 64、ターゲットプロセス 32
			info := 26, szPBI := 8, offsetPEB := 0
		else ; スクリプトとターゲットプロセスが同じビットであること
			info := 0, szPBI := PtrSize * 6, offsetPEB := PtrSize
	}
	if failed {
		DllCall("CloseHandle", Ptr, hProc)
		MsgBox, % failed 関数へのポインタの取得に失敗しました。
		Return
	}
	VarSetCapacity(PBI, 48, 0)
	if DllCall(QueryInformationProcess, Ptr, hProc, UInt, info, Ptr, &PBI, UInt, szPBI, UIntP, bytes) != STATUS_SUCCESS {
		DllCall("CloseHandle", Ptr, hProc)
		Return
	}
	pPEB := NumGet(&PBI + offsetPEB, PtrType)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pPEB + PtrSize * 4, pPtr, pRUPP, PtrType, PtrSize, UIntP, bytes)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD, UShortP, szCMD, PtrType, 2, UIntP, bytes)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD + PtrSize, pPtr, pCMD, PtrType, PtrSize, UIntP, bytes)

	VarSetCapacity(buff, szCMD, 0)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pCMD, Ptr, &buff, PtrType, szCMD, UIntP, bytes)
	obj := { cmd: StrGet(&buff, "UTF-16") }

	if (GetImagePath && obj.cmd) {
		DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD - PtrSize*2, UShortP, szPATH, PtrType, 2, UIntP, bytes)
		DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD - PtrSize, pPtr, pPATH, PtrType, PtrSize, UIntP, bytes)

		VarSetCapacity(buff, szPATH, 0)
		DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pPATH, Ptr, &buff, PtrType, szPATH, UIntP, bytes)
		obj.path := StrGet(&buff, "UTF-16") . (IsWow64 ? " *32" : "")
	}
	DllCall("CloseHandle", Ptr, hProc)
Return obj
}

SeDebugPrivilege() {
	static PROCESS_QUERY_INFORMATION := 0x400, TOKEN_ADJUST_PRIVILEGES := 0x20, SE_PRIVILEGE_ENABLED := 0x2

	hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION, Int, false, UInt, DllCall("GetCurrentProcessId"), Ptr)
	DllCall("Advapi32\OpenProcessToken", Ptr, hProc, UInt, TOKEN_ADJUST_PRIVILEGES, PtrP, token)

	DllCall("Advapi32\LookupPrivilegeValue", Ptr, 0, Str, "SeDebugPrivilege", Int64P, luid)
	VarSetCapacity(TOKEN_PRIVILEGES, 16, 0)
	NumPut(1, TOKEN_PRIVILEGES, "UInt")
	NumPut(luid, TOKEN_PRIVILEGES, 4, "Int64")
	NumPut(SE_PRIVILEGE_ENABLED, TOKEN_PRIVILEGES, 12, "UInt")
	DllCall("Advapi32\AdjustTokenPrivileges", Ptr, token, Int, false, Ptr, &TOKEN_PRIVILEGES, UInt, 0, Ptr, 0, Ptr, 0)
	res := A_LastError
	DllCall("CloseHandle", Ptr, token)
	DllCall("CloseHandle", Ptr, hProc)
Return res ; 運が良ければ0
}


;----------------------------------------------------------
; ホットキーでプログラムのフルパスを渡すと
; 起動されていれば、
; プログラムをアクテイブにする。
; すでに、アクテイブなら最小化する。
; 起動されていなければ、起動する。
; Emeditor_exe := "D:\SOFT\ユーティリティ\テキスト補助\Emeditor\EmEditor.exe"
; #1::RunActivateMinimize("notepad.exe")
; #2::RunActivateMinimize("notepad.exe", "test.txt") 引数渡せる

RunActivateMinimize(exePass, exeOption="") {
	SplitPath, exePass, exeName
	Process, Exist, %exeName%
	Sleep, 100
	If (ErrorLevel != 0)
		IfWinNotActive, ahk_pid %ErrorLevel%
		WinActivate, ahk_pid %ErrorLevel%
	else
		WinMinimize, ahk_pid %ErrorLevel%
	else
		Run, %exePass% %exeOption%
}

;----------------------------------------------------------
;短縮URLの展開
URL_Expand(vURL) {
	req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	req.Open("HEAD", "%vURL%")
	req.Option(6) := False ; Disable auto redirect
	req.Send()
	MsgBox, % req.GetResponseHeader("Location") ;URLだけ取得
	; MsgBox, % req.getAllResponseHeaders() ;すべての HTTP 応答ヘッダーを取得
}


;----------------------------------------------------------
;Bluetooth接続
;CnctBthDvc("AirPods Pro")
;CnctBthDvc("W8")

CnctBthDvc(deviceName){
	DllCall("LoadLibrary", "str", "Bthprops.cpl", "ptr")
	toggle := toggleOn := 1
	VarSetCapacity(BLUETOOTH_DEVICE_SEARCH_PARAMS, 24+A_PtrSize*2, 0)
	NumPut(24+A_PtrSize*2, BLUETOOTH_DEVICE_SEARCH_PARAMS, 0, "uint")
	NumPut(1, BLUETOOTH_DEVICE_SEARCH_PARAMS, 4, "uint") ; fReturnAuthenticated
	VarSetCapacity(BLUETOOTH_DEVICE_INFO, 560, 0)
	NumPut(560, BLUETOOTH_DEVICE_INFO, 0, "uint")
	loop {
		If(A_Index = 1){
			foundedDevice := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", &BLUETOOTH_DEVICE_SEARCH_PARAMS, "ptr", &BLUETOOTH_DEVICE_INFO)
			if !foundedDevice{
				Notify("no bluetooth devices", "", -3, "Style=Warning")
				return
			}
		}else{
			if !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", foundedDevice, "ptr", &BLUETOOTH_DEVICE_INFO){
				Notify("no found", "", -3, "Style=Warning")
				break
			}
		}
		if (StrGet(&BLUETOOTH_DEVICE_INFO+64) = deviceName){
			VarSetCapacity(Handsfree, 16)
			DllCall("ole32\CLSIDFromString", "wstr", "{0000111e-0000-1000-8000-00805f9b34fb}", "ptr", &Handsfree) ; https://www.bluetooth.com/specifications/assigned-numbers/service-discovery/
			VarSetCapacity(AudioSink, 16)
			DllCall("ole32\CLSIDFromString", "wstr", "{0000110b-0000-1000-8000-00805f9b34fb}", "ptr", &AudioSink)
			loop{
				hr := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", toggle) ; voice
				if (hr = 0){
					if (toggle = toggleOn)
						break
					toggle := !toggle
				}
				if (hr = 87)
					toggle := !toggle
			}
			loop{
				hr := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", toggle) ; music
				if (hr = 0){
					if (toggle = toggleOn)
						break 2
					toggle := !toggle
				}
				if (hr = 87)
					toggle := !toggle
			}
		}
	}
	DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", foundedDevice)
	; msgbox done
	Sleep, 100
	Send, ^!w ;FxSoundの切り替えグローバル Ctrl+Alt+W/S
	Notify("イヤホン切り替え", "", -2, "Style=Huge")
return
}

;----------------------------------------------------------
; Btn clicker
; Scaler2用(フットペダル)
; Hotkeys to move left/right
; *Right::btn_move_click_scaler(1)
; *Left::btn_move_click_scaler(0)

btn_move_click_scaler(dir) {
	Static x_arr := [170, 265, 355, 447, 537, 633, 723, 814, 907] ; x 座標の配列Array of your x coords
	, index := 1 ; 現在いる配列のインデックスを追跡するTrack the array index you're at
	If (dir) ; If dir 1 (right)
		index++ ; インデックスを1つ増加させるIncrement the index by 1
	Else index-- ; Elseで１つ減少Else decrement by 1
		If (index < x_arr.MinIndex()) ; インデックスが最小未満の場合If index is less than min
		index := x_arr.MaxIndex() ; Set to max
	Else If (index > x_arr.MaxIndex()) ; インデックスが最大値より大きい場合Else if index greater than max
		index := x_arr.MinIndex() ; Set to min
	Click, % x_arr[index] " 280" ; Y座標位置 x_arrとインデックスを使用してクリックClick using x_arr and index
}



;----------------------------------------------------------

;Chrome 翻訳
Chrome_Translate() {
  Critical, On
  SetKeyDelay, -1
  SetMouseDelay, -1
  my_tooltip_function("翻訳", 750)
  Send, {RButton}
  Sleep, 80
  Send, t
  Sleep, 80
  Send, {NumpadRight}
  Send, {LButton}
  Critical, Off
}

;----------------------------------------------------------
;プロセス優先度 高
;Process_High("001.exe/002.exe/003.exe")
Process_High(Process_p1){ ;既にそのプロセスが存在している場合
    Loop,parse,Process_p1,/
    {
        Process,Exist,%A_LoopField%
        if (  NewPID:=ErrorLevel )
            Process,Priority,%NewPID%,High
    }
;    TrayTip,, 完了_High
;    SetTimer, RemoveTrayTip, 2000
    Return
}

;プロセス優先度 低
;Process_Low("001.exe/002.exe/003.exe")
Process_Low(Process_p2){ ;既にそのプロセスが存在している場合
    Loop,parse,Process_p2,/
    {
        Process,Exist,%A_LoopField%
        if (  NewPID:=ErrorLevel )
            Process,Priority,%NewPID%,Low
    }
;    TrayTip,, 完了_Low
;    SetTimer, RemoveTrayTip, 2000
    Return
}

    RemoveTrayTip:
    SetTimer, RemoveTrayTip, Off
    Return
    exitapp             ;settimer,pt,off
    Return



;----------------------------------------------------------
; Alt+Tab一覧からソフトを消す
; https://learn.microsoft.com/ja-jp/windows/win32/winmsg/extended-window-styles
; WS_EX_TOOLWINDOW 0x00000080L
; AltTab_Remover("ahk_class MozillaWindowClass") ;firefox.exe

AltTab_Remover(VExe) {
	WinGet, VExeName, ProcessName, %VExe%
	if (RegExMatch(VExeName, "i)^(chrome|code|AutoHotkeyU64|explorer|javaw)$"))
	{ ;除外プロセス
		my_tooltip_function("AltTab_Remover 禁止ソフト", 1500)
		Notify("AltTab_Remover 禁止ソフト", "", -2, "Style=HugeRed")
		Return
	}
	else
	{
		; ToolTip, %vExeName%
		data:= {}
		winget hw, id, %VExe%
		if ((hw != "") && (hw != 0)) {
			if (data[hw]) {
				winset exstyle, % data[hw], ahk_id %hw%
				data.delete(hw)
			} else {
				winget es, exstyle, ahk_id %hw%
				data[hw]:= es
				winset exstyle, % (es | 0x80), ahk_id %hw%
			}
		}
	}
return
}


;----------------------------------------------------------
; 片手矢印 操作時のIME処理
; #Include %A_ScriptDir%\Lib\Acc1.ahk
; wasd_IME("up") ;無変換押しながらwasd Chrome対応版(Electron)

; #Include %A_ScriptDir%\Lib\Acc1.ahk

wasd_IME(vKey) {
Acc_Caret := Acc_ObjectFromWindow(WinExist("ahk_class Chrome_WidgetWin_1"), OBJID_CARET := 0xFFFFFFF8)
Caret_Location := Acc_Location(Acc_Caret)
; Caret_Location.x
; Caret_Location.y
; ToolTip, % Caret_Location.x "`n" Caret_Location.y "`n" A_CaretX
	if (Caret_Location.x > 0 or Caret_Location.y >= -1 or A_CaretX >= 1) ;キャレット有
	; if (A_CaretX > 0) ;簡易版
	{
		if (IME_GET == 1) ;IME On
		{
			GoSub, key_%vKey%
			IME_SET(1)
		}
		else ;IME Off
		{
			GoSub, key_%vKey%
			IME_SET(0)
		}
	}
	else ;キャレット無
	{
		GoSub, key_%vKey%
		IME_SET(0)
	}
}

	key_up:
	my_tooltip_function_Caret("↑", 150)
	Send, {Blind}{Up}
	Return

	key_down:
	my_tooltip_function_Caret("↓", 150)
	Send, {Blind}{Down}
	Return

	key_left:
	my_tooltip_function_Caret("←", 150)
	Send, {Blind}{Left}
	Return

	key_right:
	my_tooltip_function_Caret("→", 150)
	Send, {Blind}{Right}
	Return


;----------------------------------------------------------
; Explorer 選択ファイル2 フルパス
; Explorer_GetSelection()
Explorer_GetSelection(hwnd="") {
	If WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") || WinActive("ahk_class Progman") {
		WinHWND := WinActive()
		For win in ComObjCreate("Shell.Application").Windows
		If (win.HWND = WinHWND) {
			sel := win.Document.SelectedItems
			for item in sel
				ToReturn .= item.path "`n"
			ToReturnFinal := Trim(ToReturn,"`n")
			if (ToReturnFinal == ""){
				dir := SubStr(win.LocationURL, 9) ; remove "file:///"
				ToReturnFinal := RegExReplace(dir, "%20", " ")
			}
		}
	}
return %ToReturnFinal%
}

;----------------------------------------------------------
; プロセスkill
Kill_Process(vExe) {
	While WinExist("ahk_exe %vExe%")
	{
		Process, Close, %vExe%
	}
}

;----------------------------------------------------------
; ホットキーでプログラムのフルパスを渡すと
; 起動されていれば、
; プログラムをアクテイブにする。
; すでに、アクテイブなら最小化する。
; 起動されていなければ、起動する。
; #1::RunActivateMinimize("notepad.exe")
; #2::RunActivateMinimize("notepad.exe", "test.txt") 引数渡せる

RunActivateMinimize(exePass, exeOption="") {
  SplitPath, exePass, exeName
    Process, Exist, %exeName%
    Sleep, 200
    If (ErrorLevel != 0)
    IfWinNotActive, ahk_pid %ErrorLevel%
        WinActivate, ahk_pid %ErrorLevel%
    else
      WinMinimize, ahk_pid %ErrorLevel%
    else
      Run, %exePass% %exeOption%
}

; =================================================================================================================================
; Name:           Dimmer box
; Description:    Dim selected windows with an overlay box
; credits:        Speedmaster, Skwire
; Topic:          https://www.autohotkey.com/boards/viewtopic.php?f=6&t=78587
; Sript version:  1.0
; AHK Version:    1.1.24.03 (A32/U32/U64)
; TIPS:[Class] WinHookと組み合わせて使用

;Dimmer_box("ahk_exe foobar2000.exe")

Dimmer_box(VExe) {
	;winid:=""
	WinGetPos, X, Y, W, H, %VExe%
	WinGet, winid,, %VExe%

	if instr(idlist, winid) {
		for k, v in strsplit(idlist, "_") {
			if (v) {
				WinGetPos, X, Y, W, H, % "ahk_id " . v
				if w
					Gui, dim_%k% : Show, % "x" . x . "y" . y . "w" . w . "h" . h, Overlay
				else
					Gui, dim_%k% : Destroy
			}
		}
		return
	}

	if instr(excludelist, winid)
		return

	if !winid
		return

	dimcount++

	if winid
		idlist .= winid "_"

	; thx Skwire
	Gui, dim_%dimcount% : +Toolwindow -Caption +Lastfound +AlwaysOnTop
	Gui, dim_%dimcount% : Color, black ; Change overlay colour here.
	Gui, dim_%dimcount% : Show, % "x" . x . "y" . y . "w" . w . "h" . h, Overlay
	GUI_ID := WinExist()

	excludelist .= gui_id

	WinSet, Transparent, 50 , % "ahk_id " . GUI_ID ; Change the numerical value for opaqueness amount.
	WinSet, ExStyle , +0x00000020, % "ahk_id " . GUI_ID ; Leave this value alone
Return

Dimmer_box_Off:
	loop, % dimcount
		Gui, dim_%a_index% : Destroy

	idlist:=excludelist:=dimcount:=winid:=""

return
}


;----------------------------------------------------------
; simple_countdown(30) 30秒 ToolTip版同梱
simple_countdown(cd) {
	Loop % cd ;カウントとあわせないとマイナスになる
	{
		;ToolTip, % (cd+1) - A_Index ; A_Index を使用する場合、1 2 3 から始まります。
		SplashImage,,B1 FS40 WS900 W70, % (cd+1) - A_Index
		Sleep 1000 ;１秒
	}
	;ToolTip, 0
	SplashImage, Off
}
