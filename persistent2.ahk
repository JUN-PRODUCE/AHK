if (A_ComputerName = "SYCOM") {

	;---------------------------------------------------------------------
	; [Class] WatchFolder
	WatchFolder("X:\DL", "X_DL")
	WatchFolder("D:\", "D_dir")
	WatchFolder("D:\_mov", "D_mov")


	; WatchFolder("**PAUSE", True)

	X_DL(Directory, Changes)
	{
		For Each, Change In Changes
		{
			vAction := Change.Action
			vName := Change.Name
			SplitPath vName,,, vExt ;拡張子抽出
			; -------------------------------------------------------------------------------------------------------------------------
			; Action 1 (added) = File gets added in the watched folder
			If (vAction = 1)
			{
				If RegExMatch(vName, "(hoge|hogehoge|moge).*\.(rar|cbz)$")
				{
					Sleep, 500
					Run, %gUnifyZip%UnifyZip.exe "%vName%", %gUnifyZip%,, Hide
					my_tooltip_function("●Unzip自動処理 完了", 950)
					Notify("Unzip自動処理 完了", "", -1, "Style=Fast")
				}
				else If RegExMatch(vName, "(hoge|hogehoge|moge).*\.(zip|rar)$")
				{
					Sleep, 500
					Run, %gallrename%allrename.exe /auto1 "%vName%", %gallrename%,, Hide
					my_tooltip_function("●リネーム自動処理 完了", 950)
					Notify("リネーム自動処理 完了", "", -1, "Style=Fast")
				}
				else If RegExMatch(name, "(\(C[0-9]{2,3}\)).*\.(zip)$")
				{
					Sleep, 500
					Run, %gallrename%allrename.exe /auto1 "%vName%", %gallrename%,, Hide
					my_tooltip_function("●リネーム自動処理 完了", 950)
					Notify("リネーム自動処理 完了", "", -1, "Style=Fast")
				}
			}
		}
	}

	D_dir(Directory, Changes)
	{
		For Each, Change In Changes
		{
			vAction := Change.Action
			vName := Change.Name
			SplitPath vName,,, vExt ;拡張子抽出
			; -------------------------------------------------------------------------------------------------------------------------
			; Action 1 (added) = File gets added in the watched folder
			If (vAction = 1)
			{
				if (RegExMatch(vExt, "i)^(part|bc!|tmp|temp)$"))
				{
					Return
				}
				else if (RegExMatch(vExt, "mp4"))
				{
					Sleep, 500
					Run, %gallrename%allrename.exe /auto1 "%vName%", %gallrename%,, Hide
					my_tooltip_function("●リネーム自動処理 完了", 950)
					Notify("リネーム自動処理 完了", "", -1, "Style=Fast")
				}
			}
		}
	}

	D_mov(Directory, Changes)
	{
		For Each, Change In Changes
		{
			vAction := Change.Action
			vName := Change.Name
			SplitPath vName,,, vExt ;拡張子抽出
			; -------------------------------------------------------------------------------------------------------------------------
			; Action 1 (added) = File gets added in the watched folder
			If (vAction = 1)
			{
				If RegExMatch(vExt, "mp4")
				{
					Sleep, 500
					Run, %gallrename%allrename.exe /auto1 "%vName%", %gallrename%,, Hide
					my_tooltip_function("●リネーム自動処理 完了", 950)
					Notify("リネーム自動処理 完了", "", -1, "Style=Fast")
				}
			}
		}
	}

	;---------------------------------------------------------------------
	; [Class] WinHook
	; Add(Func, wTitle:="", wClass:="", wExe:="", Event:=0)

	; WinHook.Shell.Add("Created",,, "javaw.exe",1)
	; WinHook.Shell.Add("Created",,, "BitComet_x64.exe",1)
	WinHook.Shell.Add("Created",,, "mpc-hc64.exe",1)
	WinHook.Shell.Add("Created",,, "vlc.exe",1)
	WinHook.Shell.Add("Created",,, "i_view64.exe",1)
	WinHook.Shell.Add("Created",,, "Ralpha.exe",1)
	WinHook.Shell.Add("Created", "エラーログ",, "Ralpha.exe",1)
	WinHook.Shell.Add("Created",,, "UnifyZip.exe",1)
	WinHook.Shell.Add("Created", "Playback error", "#32770", "foobar2000.exe",1)
	WinHook.Shell.Add("Created", "ShareX - Optical character recognition",,,1)

	; WinHook.Shell.Add("Activated",,, "javaw.exe",4)
	; WinHook.Shell.Add("Activated",,, "javaw.exe",32772)
	; WinHook.Shell.Add("Activated",,, "BitComet_x64.exe",4)
	; WinHook.Shell.Add("Activated",,, "BitComet_x64.exe",32772)

	; WinHook.Shell.Add("Destroyed",,, "javaw.exe",2)
	; WinHook.Shell.Add("Destroyed",,, "BitComet_x64.exe",2)
	WinHook.Shell.Add("Destroyed",,, "i_view64.exe",2)
	; WinHook.Shell.Add("Destroyed",,, "mpc-hc64.exe",2)
	;WinHook.Shell.Add("Destroyed",,, "scrcpy.exe",2)
	WinHook.Shell.Add("Destroyed",,, "MangaMeeya.exe",2)
	; WinHook.Shell.Add("Destroyed",,, "JDownloader2.exe",2)

	; WinHook.Event.Add(3, 3, "ForeGroundChange")

	;---------------------------------------------------------------------

	Created(Win_Hwnd, Win_Title, Win_Class, Win_Exe, Win_Event)
	{
		if (Win_Exe = "mpc-hc64.exe")
		{
			Process_High("mpc-hc64.exe")
			Return
		}
		Else if (Win_Exe = "vlc.exe")
		{
			Process_High("vlc.exe")
			Return
		}
		Else if (Win_Exe = "i_view64.exe")
		{
			Process_High("i_view64.exe")
			Return
		}
		Else if (Win_Exe = "Ralpha.exe") || (Win_Exe = "UnifyZip.exe")
		{
			PostMessage, 0x0112, 0xF020,,, ahk_class TProgressForm ahk_exe Ralpha.exe
			PostMessage, 0x0112, 0xF020,,, ahk_class ConsoleWindowClass ahk_exe UnifyZip.exe
			Return
		}
		Else if (Win_Title = "Playback error") ;foobar2000
		{
			Sleep, 800
			; Send, {Escape}
			MsgBox,,, ahk_class #32770
			WinClose, ahk_class #32770
			Return
		}
		Else if (Win_Title = "エラーログ") ;Ralpha
		{
			Sleep, 100
			; ControlClick, TButton1, ahk_class TErrorLogForm,, LEFT, 2, NA
			; ControlSend, Close, {Space}, ahk_class TErrorLogForm
			WinClose, ahk_class TErrorLogForm
			Return
		}
		Else if (Win_Title = "ShareX - Optical character recognition")
		{
			GoSub, OCR_Jp_Fix
			Send, ^a
			Return
		}
		; Else if (Win_Exe = "javaw.exe") || (Win_Exe = "BitComet_x64.exe")
		; {
		; 	GoSub, Dimmer_box_On
		; 	Return
		; }

		WinGet, PID, PID, ahk_id %Win_Hwnd%
		EH1 := WinHook.Event.Add(0x0016, 0x0016, "Minimized", PID)
		EH2 := WinHook.Event.Add(0x0017, 0x0017, "Restored", PID)
	}

	Destroyed(Win_Hwnd, Win_Title, Win_Class, Win_Exe, Win_Event)
	{
		; if (Win_Exe = "javaw.exe") || (Win_Exe = "BitComet_x64.exe")
		; {
		; 	GoSub, Dimmer_box_Off
		; 	WinActivate, ahk_class FreeCommanderXE.SingleInst.1
		; 	GoSub, Dimmer_box_On
		; 	Return
		; }
		if (Win_Exe = "i_view64.exe")
		{
			; Run, D:\SOFT\ユーティリティ\デスクトップ補助\Rainmeter\RestartRainmeter.exe.lnk, D:\SOFT\ユーティリティ\デスクトップ補助\Rainmeter\, Hide
			PostMessage, 0x111, 4001,,, ahk_exe Rainmeter.exe ahk_class RainmeterMeterWindow
			; PostMessage, 0x111, 4001,,, ahk_id 0xFFFF
			Return
		}
		else if (Win_Exe = "mpc-hc64__.exe") || (Win_Exe = "MangaMeeya.exe") || (Win_Exe = "vlc.exe")
		{
			if WinExist("ahk_exe mpc-hc64__.exe") || WinExist("ahk_exe MangaMeeya.exe")
			{ ;次のファイルに移動するとDestroyed判定するため
				Return
			}
			else
			{
				Sleep, 50
				WinActivate, ahk_class FreeCommanderXE.SingleInst.1
			}
			Return
		}
		; else if (Win_Exe = "JDownloader2.exe") {
		; 	if WinExist("ahk_exe JDownloader2.exe") {
		; 		Return
		; 	} else {
		; 		Run, D:\SOFT\インターネット\ダウンロード\JDownloader_2\JDownloader2.exe, D:\SOFT\インターネット\ダウンロード\JDownloader_2\,,
		; 	}
		; Return
		; }	; else if (Win_Exe = "scrcpy.exe") {
		; 	Run, adb shell input keyevent KEYCODE_SLEEP,, Hide
		; Return
		; }
	}

	; Minimized(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
	; {
	; 	if (Win_Event = 17) {
	; 		if (Win_Exe = "javaw.exe") || (Win_Exe = "BitComet_x64.exe") {
	; 			GoSub, Dimmer_box_Off
	; 			MsgBox,,,min
	; 			Return
	; 		}
	; 	}
	; }

	; Restored(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
	; {
	; 	if (Win_Exe = "javaw.exe") || (Win_Exe = "BitCofmet_x64.exe") {
	; 		GoSub, Dimmer_box_Off
	; 		WinActivate, ahk_class FreeCommanderXE.SingleInst.1
	; 		GoSub, Dimmer_box_On
	; 		MsgBox,,,rest
	; 		Return
	; 	}
	; }

	; Activated(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
	; {
	; 	if ((Win_Event = 4) || (Win_Event = 32772)) {
	; 		if (Win_Exe = "javaw.exe") || (Win_Exe = "BitComet_x64.exe") {
	; 			MsgBox,,,active
	; 			GoSub, Dimmer_box_On
	; 			Return
	; 		}
	; 	}
	; }

	; ForeGroundChange(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
	; {
	; 	WinGetClass, Class, ahk_id %hwnd%
	; 	If (Class = "DocFetcher")
	; 		ToolTip, on
	; 	else
	; 		GoSub, Dimmer_box_Off
	; 		ToolTip, off
	; }

	;対象アプリの全イベントチェック
	; WinHook.Shell.Add("AllExcelEvents", , , "i_view64.exe")
	; AllExcelEvents(Win_Hwnd, Win_Title, Win_Class, Win_Exe, Win_Event)
	; {
	; 	static
	; 	Str := Win_Event "`n" Str
	; 	ToolTip % Str
	; }

	;-------------------------------------------------------------------------------------------
	; [Class] WinHook
	; Fanatic Guru
	; 2019 02 18 v2
	;
	; Class to set hooks of windows or processes
	;
	;{============================
	;
	;	Class (Nested):		WinHook.Shell
	;
	;		Method:
	; 			Add(Func, wTitle:="", wClass:="", wExe:="", Event:=0)
	;
	;		Desc: Add Shell Hook
	;
	;   	Parameters:
	;		1) {Func}		イベント時に呼び出す関数名または関数オブジェクト　Function name or Function object to call on event
	;   	2) {wTitle}		ウィンドウ イベントを監視するためのタイトル(default = "", all windows)　window Title to watch for event (default = "", all windows)
	;   	3) {wClass}		ウィンドウ イベントを監視するクラス(default = "", all windows)　window Class to watch for event (default = "", all windows)
	;   	4) {wExe}		ウィンドウ イベントを監視するExe(default = "", all windows)　window Exe to watch for event (default = "", all windows)
	;   	5) {Event}		Event (default = 0, all events)
	;
	;		Returns: {Index}	フックを削除するために使用できるフックのインデックス　index to hook that can be used to Remove hook
	;
	;				Shell Hook Events:
	;				1 = HSHELL_WINDOWCREATED
	;				2 = HSHELL_WINDOWDESTROYED
	;				3 = HSHELL_ACTIVATESHELLWINDOW
	;				4 = HSHELL_WINDOWACTIVATED
	;				5 = HSHELL_GETMINRECT
	;				6 = HSHELL_REDRAW
	;				7 = HSHELL_TASKMAN
	;				8 = HSHELL_LANGUAGE
	;				9 = HSHELL_SYSMENU
	;				10 = HSHELL_ENDTASK
	;				11 = HSHELL_ACCESSIBILITYSTATE
	;				12 = HSHELL_APPCOMMAND
	;				13 = HSHELL_WINDOWREPLACED
	;				14 = HSHELL_WINDOWREPLACING
	;				32768 = 0x8000 = HSHELL_HIGHBIT
	;				32772 = 0x8000 + 4 = 0x8004 = HSHELL_RUDEAPPACTIVATED (HSHELL_HIGHBIT + HSHELL_WINDOWACTIVATED) fullscreen用
	;				32774 = 0x8000 + 6 = 0x8006 = HSHELL_FLASH (HSHELL_HIGHBIT + HSHELL_REDRAW) fullscreen用 メインはこれ
	;
	;		Note: ObjBindMethod(obj, Method)は、クラスメソッドに関数オブジェクトを作成するために使用することができます
	;         ObjBindMethod(obj, Method) can be used to create a function object to a class method
	;					WinHook.Shell.Add(ObjBindMethod(TestClass.TestNestedClass, "MethodName"), wTitle, wClass, wExe, Event)
	;
	; ----------
	;
	;		Desc: Function Called on Event
	;			FuncOrMethod(Win_Hwnd, Win_Title, Win_Class, Win_Exe, Win_Event)
	;
	;		Parameters:
	;		1) {Win_Hwnd}	window handle ID of window with event
	;   	2) {Win_Title}		window Title of window with event
	;   	3) {Win_Class}		window Class of window with event
	;   	4) {Win_Exe}		window Exe of window with event
	;   	5) {Win_Event}		window Event
	;
	;		Note: FuncOrMethodは、DetectHiddenWindows Onで呼び出されます。
	;					FuncOrMethod will be called with DetectHiddenWindows On.
	;
	; --------------------
	;
	;		Method: 	Report(ByRef Object)
	;
	;		Desc: 		Report Shell Hooks
	;
	;		Returns:	string report
	;						ByRef	Object[Index].{Func, Title:, Class, Exe, Event}
	;
	; --------------------
	;
	;		Method:		Remove(Index)
	;		Method:		Deregister()
	;
	;{============================
	;
	;	Class (Nested):		WinHook.Event
	;
	;		Method:
	;			Add(eventMin, eventMax, eventProc, idProcess, WinTitle := "")
	;
	;		Desc: Add Event Hook
	;
	;   	Parameters:
	;	 	1) {eventMin}		フック機能で扱う最低イベント値　lowest Event value handled by the hook function
	;   	2) {eventMax}		フック関数が扱う最高イベント値　highest event value handled by the hook function
	;   	3) {eventProc}		イベントフック関数、呼び出しは関数名または関数オブジェクトです。　event hook function, call be function name or function object
	;   	4) {idProcess}		フック関数がイベントを受信するプロセスのID (default = 0, all processes)　ID of the process from which the hook function receives events (default = 0, all processes)
	;   	5) {WinTitle}		どのウィンドウで操作するかを特定するためのWinTitle。(default = "", all windows)　WinTitle to identify which windows to operate on, (default = "", all windows)
	;
	;		Returns: {hWinEventHook}	フックを外すために使用できるフックへのハンドル　handle to hook that can be used to unhook
	;
	;		イベント定数一覧
	;		https://docs.microsoft.com/ja-jp/windows/win32/winauto/event-constants
	;
	;				Event Hook Events:
	;				0x8012 = EVENT_OBJECT_ACCELERATORCHANGE
	;				0x8017 = EVENT_OBJECT_CLOAKED
	;				0x8015 = EVENT_OBJECT_CONTENTSCROLLED
	;				0x8000 = EVENT_OBJECT_CREATE
	;				0x8011 = EVENT_OBJECT_DEFACTIONCHANGE
	;				0x800D = EVENT_OBJECT_DESCRIPTIONCHANGE
	;				0x8001 = EVENT_OBJECT_DESTROY
	;				0x8021 = EVENT_OBJECT_DRAGSTART
	;				0x8022 = EVENT_OBJECT_DRAGCANCEL
	;				0x8023 = EVENT_OBJECT_DRAGCOMPLETE
	;				0x8024 = EVENT_OBJECT_DRAGENTER
	;				0x8025 = EVENT_OBJECT_DRAGLEAVE
	;				0x8026 = EVENT_OBJECT_DRAGDROPPED
	;				0x80FF = EVENT_OBJECT_END
	;				0x8005 = EVENT_OBJECT_FOCUS
	;				0x8010 = EVENT_OBJECT_HELPCHANGE
	;				0x8003 = EVENT_OBJECT_HIDE
	;				0x8020 = EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED
	;				0x8028 = EVENT_OBJECT_IME_HIDE
	;				0x8027 = EVENT_OBJECT_IME_SHOW
	;				0x8029 = EVENT_OBJECT_IME_CHANGE
	;				0x8013 = EVENT_OBJECT_INVOKED
	;				0x8019 = EVENT_OBJECT_LIVEREGIONCHANGED
	;				0x800B = EVENT_OBJECT_LOCATIONCHANGE
	;				0x800C = EVENT_OBJECT_NAMECHANGE
	;				0x800F = EVENT_OBJECT_PARENTCHANGE
	;				0x8004 = EVENT_OBJECT_REORDER
	;				0x8006 = EVENT_OBJECT_SELECTION
	;				0x8007 = EVENT_OBJECT_SELECTIONADD
	;				0x8008 = EVENT_OBJECT_SELECTIONREMOVE
	;				0x8009 = EVENT_OBJECT_SELECTIONWITHIN
	;				0x8002 = EVENT_OBJECT_SHOW
	;				0x800A = EVENT_OBJECT_STATECHANGE
	;				0x8030 = EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED
	;				0x8014 = EVENT_OBJECT_TEXTSELECTIONCHANGED
	;				0x8018 = EVENT_OBJECT_UNCLOAKED
	;				0x800E = EVENT_OBJECT_VALUECHANGE
	;				0x0002 = EVENT_SYSTEM_ALERT
	;				0x8016 = EVENT_SYSTEM_ARRANGMENTPREVIEW
	;				0x0009 = EVENT_SYSTEM_CAPTUREEND
	;				0x0008 = EVENT_SYSTEM_CAPTURESTART
	;				0x000D = EVENT_SYSTEM_CONTEXTHELPEND
	;				0x000C = EVENT_SYSTEM_CONTEXTHELPSTART
	;				0x0020 = EVENT_SYSTEM_DESKTOPSWITCH
	;				0x0011 = EVENT_SYSTEM_DIALOGEND
	;				0x0010 = EVENT_SYSTEM_DIALOGSTART
	;				0x000F = EVENT_SYSTEM_DRAGDROPEND
	;				0x000E = EVENT_SYSTEM_DRAGDROPSTART
	;				0x00FF = EVENT_SYSTEM_END
	;				0x0003 = EVENT_SYSTEM_FOREGROUND
	;				0x0007 = EVENT_SYSTEM_MENUPOPUPEND
	;				0x0006 = EVENT_SYSTEM_MENUPOPUPSTART
	;				0x0005 = EVENT_SYSTEM_MENUEND
	;				0x0004 = EVENT_SYSTEM_MENUSTART
	;				0x0017 = EVENT_SYSTEM_MINIMIZEEND
	;				0x0016 = EVENT_SYSTEM_MINIMIZESTART
	;				0x000B = EVENT_SYSTEM_MOVESIZEEND
	;				0x000A = EVENT_SYSTEM_MOVESIZESTART
	;				0x0013 = EVENT_SYSTEM_SCROLLINGEND
	;				0x0012 = EVENT_SYSTEM_SCROLLINGSTART
	;				0x0001 = EVENT_SYSTEM_SOUND
	;				0x0015 = EVENT_SYSTEM_SWITCHEND
	;				0x0014 = EVENT_SYSTEM_SWITCHSTART
	;
	;		Note: ObjBindMethod(obj, Method) can be used to create a function object to a class method
	;					WinHook.Event.Add((eventMin, eventMax, ObjBindMethod(TestClass.TestNestedClass, "MethodName"), idProcess, WinTitle := "")
	;
	; ----------
	;
	;		Desc: ObjBindMethod(obj, Method)は、クラスメソッドに関数オブジェクトを作成するために使用することができます
	;     Function Called on Event
	;			FuncOrMethod(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
	;
	;		Parameters:
	;		1) {hWinEventHook}		イベントフックインスタンスへのハンドル。　Handle to an event hook instance.
	;   	2) {event}						発生したイベント この値はイベント定数の一つである　Event that occurred. This value is one of the event constants
	;   	3) {hwnd}						イベントを発生させたウィンドウへのハンドル。　Handle to the window that generates the event.
	;   	4) {idObject}					イベントに関連するオブジェクトを識別する。　Identifies the object that is associated with the event.
	;   	5) {idChild}					イベントが子要素によって引き起こされた場合、子ID。Child ID if the event was triggered by a child element.
	;   	6) {dwEventThread}		イベントを発生させたスレッドを特定する。　Identifies the thread that generated the event.
	;   	7) {dwmsEventTime}		イベントが発生した時刻をミリ秒単位で指定する。　Specifies the time, in milliseconds, that the event was generated.
	;
	;		Note: FuncOrMethodは、DetectHiddenWindows Onで呼び出されます。
	;         FuncOrMethod will be called with DetectHiddenWindows On.
	;
	; --------------------
	;
	;		Method:	Report(ByRef Object)
	;
	;		Returns:	string report
	;						ByRef	Object[hWinEventHook].{eventMin, eventMax, eventProc, idProcess, WinTitle}
	;
	; --------------------
	;
	;		Method: 	UnHook(hWinEventHook)
	;		Method: 	UnHookAll()
	;
	;{============================
	class WinHook
	{
		class Shell
		{
			Add(Func, wTitle:="", wClass:="", wExe:="", Event:=0)
			{
				if !WinHook.Shell.Hooks
				{
					WinHook.Shell.Hooks := {}, WinHook.Shell.Events := {}
					DllCall("RegisterShellHookWindow", UInt, A_ScriptHwnd)
					MsgNum := DllCall("RegisterWindowMessage", Str, "SHELLHOOK")
					OnMessage(MsgNum, ObjBindMethod(WinHook.Shell, "Message"))
				}
				if !IsObject(Func)
					Func := Func(Func)
				WinHook.Shell.Hooks.Push({Func: Func, Title: wTitle, Class: wClass, Exe: wExe, Event: Event})
				WinHook.Shell.Events[Event] := true
				return WinHook.Shell.Hooks.MaxIndex()
			}
			Remove(Index)
			{
				WinHook.Shell.Hooks.Delete(Index)
				WinHook.Shell.Events[Event] := {}	; delete and rebuild Event list
				For key, Hook in WinHook.Shell.Hooks
					WinHook.Shell.Events[Hook.Event] := true
			}
			Report(ByRef Obj:="")
			{
				Obj := WinHook.Shell.Hooks
				For key, Hook in WinHook.Shell.Hooks
					Display .= key "|" Hook.Event "|" Hook.Func.Name "|" Hook.Title "|" Hook.Class "|" Hook.Exe "`n"
				return Trim(Display, "`n")
			}
			Deregister()
			{
				DllCall("DeregisterShellHookWindow", UInt, A_ScriptHwnd)
				WinHook.Shell.Hooks := "", WinHook.Shell.Events := ""
			}
			Message(Event, Hwnd) ; Private Method
			{
				DetectHiddenWindows, On
				If (WinHook.Shell.Events[Event] or WinHook.Shell.Events[0])
				{

					WinGetTitle, wTitle, ahk_id %Hwnd%
					WinGetClass, wClass, ahk_id %Hwnd%
					WinGet, wExe, ProcessName, ahk_id %Hwnd%
					for key, Hook in WinHook.Shell.Hooks
						if ((Hook.Title = wTitle or Hook.Title = "") and (Hook.Class = wClass or Hook.Class = "") and (Hook.Exe = wExe or Hook.Exe = "") and (Hook.Event = Event or Hook.Event = 0))
						return Hook.Func.Call(Hwnd, wTitle, wClass, wExe, Event)
				}
			}
		}
		class Event
		{
			Add(eventMin, eventMax, eventProc, idProcess := 0, WinTitle := "")
			{
				if !WinHook.Event.Hooks
				{
					WinHook.Event.Hooks := {}
					static CB_WinEventProc := RegisterCallback(WinHook.Event.Message)
					OnExit(ObjBindMethod(WinHook.Event, "UnHookAll"))
				}
				hWinEventHook := DllCall("SetWinEventHook"
					, "UInt",	eventMin						;  UINT eventMin
					, "UInt",	eventMax						;  UINT eventMax
					, "Ptr" ,	0x0								;  HMODULE hmodWinEventProc
					, "Ptr" ,	CB_WinEventProc					;  WINEVENTPROC lpfnWinEventProc
					, "UInt" ,	idProcess						;  DWORD idProcess
					, "UInt",	0x0								;  DWORD idThread
				, "UInt",	0x0|0x2) 						;  UINT dwflags, OutOfContext|SkipOwnProcess
				if !IsObject(eventProc)
					eventProc := Func(eventProc)
				WinHook.Event.Hooks[hWinEventHook] := {eventMin: eventMin, eventMax: eventMax, eventProc: eventProc, idProcess: idProcess, WinTitle: WinTitle}
				return hWinEventHook
			}
			Report(ByRef Obj:="")
			{
				Obj := WinHook.Event.Hooks
				For hWinEventHook, Hook in WinHook.Event.Hooks
					Display .= hWinEventHook "|" Hook.eventMin "|" Hook.eventMax "|" Hook.eventProc.Name "|" Hook.idProcess "|" Hook.WinTitle "`n"
				return Trim(Display, "`n")
			}
			UnHook(hWinEventHook)
			{
				DllCall("UnhookWinEvent", "Ptr", hWinEventHook)
				WinHook.Event.Hooks.Delete(hWinEventHook)
			}
			UnHookAll()
			{
				for hWinEventHook, Hook in WinHook.Event.Hooks
					DllCall("UnhookWinEvent", "Ptr", hWinEventHook)
				WinHook.Event.Hooks := "", CB_WinEventProc := ""
			}
			Message(event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) ; 'Private Method
			{
				DetectHiddenWindows, On
				Hook := WinHook.Event.Hooks[hWinEventHook := this] ; this' is hidden param1 because method is called as func
				WinGet, List, List, % Hook.WinTitle
				Loop % List
					if (List%A_Index% = hwnd)
					return Hook.eventProc.Call(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
			}
		}
	}

	; ==================================================================================================================================
	; Function:       Notifies about changes within folders.
	;                 This is a rewrite of HotKeyIt's WatchDirectory() released at
	;                    http://www.autohotkey.com/board/topic/60125-ahk-lv2-watchdirectory-report-directory-changes/
	; Tested with:    AHK 1.1.23.01 (A32/U32/U64)
	; Tested on:      Win 10 Pro x64
	; Usage:          WatchFolder(Folder, UserFunc[, SubTree := False[, Watch := 3]])
	; Parameters:
	;     Folder      -  The full qualified path of the folder to be watched.
	;                    Pass the string "**PAUSE" and set UserFunc to either True or False to pause respectively resume watching.
	;                    Pass the string "**END" and an arbitrary value in UserFunc to completely stop watching anytime.
	;                    If not, it will be done internally on exit.
	;     UserFunc    -  The name of a user-defined function to call on changes. The function must accept at least two parameters:
	;                    1: The path of the affected folder. The final backslash is not included even if it is a drive's root
	;                       directory (e.g. C:).
	;                    2: An array of change notifications containing the following keys:
	;                       Action:  One of the integer values specified as FILE_ACTION_... (see below).
	;                                In case of renaming Action is set to FILE_ACTION_RENAMED (4).
	;                       Name:    The full path of the changed file or folder.
	;                       OldName: The previous path in case of renaming, otherwise not used.
	;                       IsDir:   True if Name is a directory; otherwise False. In case of Action 2 (removed) IsDir is always False.
	;                    Pass the string "**DEL" to remove the directory from the list of watched folders.
	;     SubTree     -  Set to true if you want the whole subtree to be watched (i.e. the contents of all sub-folders).
	;                    Default: False - sub-folders aren't watched.
	;     Watch       -  The kind of changes to watch for. This can be one or any combination of the FILE_NOTIFY_CHANGES_...
	;                    values specified below.
	;                    Default: 0x03 - FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
	; Return values:
	;     Returns True on success; otherwise False.
	; Change history:
	;     1.0.03.00/2021-10-14/just me        -  bug-fix for addding, removing, or updating folders.
	;     1.0.02.00/2016-11-30/just me        -  bug-fix for closing handles with the '**END' option.
	;     1.0.01.00/2016-03-14/just me        -  bug-fix for multiple folders
	;     1.0.00.00/2015-06-21/just me        -  initial release
	; License:
	;     The Unlicense -> http://unlicense.org/
	; Remarks:
	;     Due to the limits of the API function WaitForMultipleObjects() you cannot watch more than MAXIMUM_WAIT_OBJECTS (64)
	;     folders simultaneously.
	; MSDN:
	;     ReadDirectoryChangesW          msdn.microsoft.com/en-us/library/aa365465(v=vs.85).aspx
	;     FILE_NOTIFY_CHANGE_FILE_NAME   = 1   (0x00000001) : Notify about renaming, creating, or deleting a file.
	;     FILE_NOTIFY_CHANGE_DIR_NAME    = 2   (0x00000002) : Notify about creating or deleting a directory.
	;     FILE_NOTIFY_CHANGE_ATTRIBUTES  = 4   (0x00000004) : Notify about attribute changes.
	;     FILE_NOTIFY_CHANGE_SIZE        = 8   (0x00000008) : Notify about any file-size change.
	;     FILE_NOTIFY_CHANGE_LAST_WRITE  = 16  (0x00000010) : Notify about any change to the last write-time of files.
	;     FILE_NOTIFY_CHANGE_LAST_ACCESS = 32  (0x00000020) : Notify about any change to the last access time of files.
	;     FILE_NOTIFY_CHANGE_CREATION    = 64  (0x00000040) : Notify about any change to the creation time of files.
	;     FILE_NOTIFY_CHANGE_SECURITY    = 256 (0x00000100) : Notify about any security-descriptor change.
	;     FILE_NOTIFY_INFORMATION        msdn.microsoft.com/en-us/library/aa364391(v=vs.85).aspx
	;     FILE_ACTION_ADDED              = 1   (0x00000001) : The file was added to the directory.
	;     FILE_ACTION_REMOVED            = 2   (0x00000002) : The file was removed from the directory.
	;     FILE_ACTION_MODIFIED           = 3   (0x00000003) : The file was modified.
	;     FILE_ACTION_RENAMED            = 4   (0x00000004) : The file was renamed (not defined by Microsoft).
	;     FILE_ACTION_RENAMED_OLD_NAME   = 4   (0x00000004) : The file was renamed and this is the old name.
	;     FILE_ACTION_RENAMED_NEW_NAME   = 5   (0x00000005) : The file was renamed and this is the new name.
	;     GetOverlappedResult            msdn.microsoft.com/en-us/library/ms683209(v=vs.85).aspx
	;     CreateFile                     msdn.microsoft.com/en-us/library/aa363858(v=vs.85).aspx
	;     FILE_FLAG_BACKUP_SEMANTICS     = 0x02000000
	;     FILE_FLAG_OVERLAPPED           = 0x40000000
	; ==================================================================================================================================
	WatchFolder(Folder, UserFunc, SubTree := False, Watch := 0x03) {
		Static DummyObject := {Base: {__Delete: Func("WatchFolder").Bind("**END", "")}}
		Static TimerID := "**" . A_TickCount
		Static TimerFunc := Func("WatchFolder").Bind(TimerID, "")
		Static MAXIMUM_WAIT_OBJECTS := 64
		Static MAX_DIR_PATH := 260 - 12 + 1
		Static SizeOfLongPath := MAX_DIR_PATH << !!A_IsUnicode
		Static SizeOfFNI := 0xFFFF ; size of the FILE_NOTIFY_INFORMATION structure buffer (64 KB)
		Static SizeOfOVL := 32 ; size of the OVERLAPPED structure (64-bit)
		Static WatchedFolders := {}
		Static EventArray := []
		Static WaitObjects := 0
		Static BytesRead := 0
		Static Paused := False
		; ===============================================================================================================================
		If (Folder = "")
			Return False
		SetTimer, % TimerFunc, Off
		RebuildWaitObjects := False
		; ===============================================================================================================================
		If (Folder = TimerID) { ; called by timer
			If (ObjCount := EventArray.Count()) && !Paused {
				ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
				While (ObjIndex >= 0) && (ObjIndex < ObjCount) {
					Event := NumGet(WaitObjects, ObjIndex * A_PtrSize, "UPtr")
					Folder := EventArray[Event]
					If DllCall("GetOverlappedResult", "Ptr", Folder.Handle, "Ptr", Folder.OVLAddr, "UIntP", BytesRead, "Int", True) {
						Changes := []
						FNIAddr := Folder.FNIAddr
						FNIMax := FNIAddr + BytesRead
						OffSet := 0
						PrevIndex := 0
						PrevAction := 0
						PrevName := ""
						Loop {
							FNIAddr += Offset
							OffSet := NumGet(FNIAddr + 0, "UInt")
							Action := NumGet(FNIAddr + 4, "UInt")
							Length := NumGet(FNIAddr + 8, "UInt") // 2
							Name := Folder.Name . "\" . StrGet(FNIAddr + 12, Length, "UTF-16")
							IsDir := InStr(FileExist(Name), "D") ? 1 : 0
							If (Name = PrevName) {
								If (Action = PrevAction)
									Continue
								If (Action = 1) && (PrevAction = 2) {
									PrevAction := Action
									Changes.RemoveAt(PrevIndex--)
									Continue
								}
							}
							If (Action = 4)
								PrevIndex := Changes.Push({Action: Action, OldName: Name, IsDir: 0})
							Else If (Action = 5) && (PrevAction = 4) {
								Changes[PrevIndex, "Name"] := Name
								Changes[PrevIndex, "IsDir"] := IsDir
							}
							Else
								PrevIndex := Changes.Push({Action: Action, Name: Name, IsDir: IsDir})
							PrevAction := Action
							PrevName := Name
						} Until (Offset = 0) || ((FNIAddr + Offset) > FNIMax)
						If (Changes.Length() > 0)
							Folder.Func.Call(Folder.Name, Changes)
						DllCall("ResetEvent", "Ptr", Event)
						DllCall("ReadDirectoryChangesW", "Ptr", Folder.Handle, "Ptr", Folder.FNIAddr, "UInt", SizeOfFNI
							, "Int", Folder.SubTree, "UInt", Folder.Watch, "UInt", 0
						, "Ptr", Folder.OVLAddr, "Ptr", 0)
					}
					ObjIndex := DllCall("WaitForMultipleObjects", "UInt", ObjCount, "Ptr", &WaitObjects, "Int", 0, "UInt", 0, "UInt")
					Sleep, 0
				}
			}
		}
		; ===============================================================================================================================
		Else If (Folder = "**PAUSE") { ; called to pause/resume watching
			Paused := !!UserFunc
			RebuildObjects := Paused
		}
		; ===============================================================================================================================
		Else If (Folder = "**END") { ; called to stop watching
			For Event, Folder In EventArray {
				DllCall("CloseHandle", "Ptr", Folder.Handle)
				DllCall("CloseHandle", "Ptr", Event)
			}
			WatchedFolders := {}
			EventArray := []
			Paused := False
			Return True
		}
		; ===============================================================================================================================
		Else { ; called to add, update, or remove folders
			Folder := RTrim(Folder, "\")
			VarSetCapacity(LongPath, MAX_DIR_PATH << !!A_IsUnicode, 0)
			If !DllCall("GetLongPathName", "Str", Folder, "Ptr", &LongPath, "UInt", MAX_DIR_PATH)
				Return False
			VarSetCapacity(LongPath, -1)
			Folder := LongPath
			If (WatchedFolders.HasKey(Folder)) { ; update or remove
				Event := WatchedFolders[Folder]
				FolderObj := EventArray[Event]
				DllCall("CloseHandle", "Ptr", FolderObj.Handle)
				DllCall("CloseHandle", "Ptr", Event)
				EventArray.Delete(Event)
				WatchedFolders.Delete(Folder)
				RebuildWaitObjects := True
			}
			If InStr(FileExist(Folder), "D") && (UserFunc <> "**DEL") && (EventArray.Count() < MAXIMUM_WAIT_OBJECTS) {
				If (IsFunc(UserFunc) && (UserFunc := Func(UserFunc)) && (UserFunc.MinParams >= 2)) && (Watch &= 0x017F) {
					Handle := DllCall("CreateFile", "Str", Folder . "\", "UInt", 0x01, "UInt", 0x07, "Ptr",0, "UInt", 0x03
					, "UInt", 0x42000000, "Ptr", 0, "UPtr")
					If (Handle > 0) {
						Event := DllCall("CreateEvent", "Ptr", 0, "Int", 1, "Int", 0, "Ptr", 0)
						FolderObj := {Name: Folder, Func: UserFunc, Handle: Handle, SubTree: !!SubTree, Watch: Watch}
						FolderObj.SetCapacity("FNIBuff", SizeOfFNI)
						FNIAddr := FolderObj.GetAddress("FNIBuff")
						DllCall("RtlZeroMemory", "Ptr", FNIAddr, "Ptr", SizeOfFNI)
						FolderObj["FNIAddr"] := FNIAddr
						FolderObj.SetCapacity("OVLBuff", SizeOfOVL)
						OVLAddr := FolderObj.GetAddress("OVLBuff")
						DllCall("RtlZeroMemory", "Ptr", OVLAddr, "Ptr", SizeOfOVL)
						NumPut(Event, OVLAddr + 8, A_PtrSize * 2, "Ptr")
						FolderObj["OVLAddr"] := OVLAddr
						DllCall("ReadDirectoryChangesW", "Ptr", Handle, "Ptr", FNIAddr, "UInt", SizeOfFNI, "Int", SubTree
						, "UInt", Watch, "UInt", 0, "Ptr", OVLAddr, "Ptr", 0)
						EventArray[Event] := FolderObj
						WatchedFolders[Folder] := Event
						RebuildWaitObjects := True
					}
				}
			}
			If (RebuildWaitObjects) {
				VarSetCapacity(WaitObjects, MAXIMUM_WAIT_OBJECTS * A_PtrSize, 0)
				OffSet := &WaitObjects
				For Event In EventArray
					Offset := NumPut(Event, Offset + 0, 0, "Ptr")
			}
		}
		; ===============================================================================================================================
		If (EventArray.Count() > 0)
			SetTimer, % TimerFunc, -100
		Return (RebuildWaitObjects) ; returns True on success, otherwise False
	}

} ;if (A_ComputerName = "SYCOM")

; if (A_ComputerName = "Surface") {

; 	SetTimer,OnTimer,1000
; 	return

; 	OnTimer:
; 		If A_TimeIdlePhysical>30000	 ;1分以上操作を行っていなければ
; 		{
; 			if flag<>1 ;実行されたかどうかのフラグが立っていなければ
; 			{
; 				Run, Powercfg -setactive 41a334b7-5d86-43a8-8963-72481f6dd9e9,,HIDE ;最高
; 				Notify("Low CPU", "", -1, "Style=Fast")
; 				flag=1 ;フラグを立てる
; 			}
; 		} else { ;最近1分以内に操作が行われた場合
; 			flag=0 ;フラグを解除する
; 			Run, Powercfg -setactive 41a334b7-5d86-43a8-8963-72481f6dd9e9,,HIDE ;最低
; 			Notify("MAX CPU", "", -1, "Style=Fast")
; 		}
; 	return

; } ;if (A_ComputerName = "Surface")
