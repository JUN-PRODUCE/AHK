;USBテンキーを音楽プレイヤー用コントローラー化
;AutoHotInterception.ahkでUSBテンキーの入力を全てハイジャック


;環境設定
#Persistent ;スクリプトを明示的に常駐させる
#SingleInstance, Force	;複数プロセスで実行の禁止
#NoEnv	;変数の処理においてWindows環境変数の探索をしない
#UseHook ;RegisterHotkeyを介さず、フックを使用してホットキーを定義する
#WinActivateForce ;ウィンドウのアクティブ化を強制的に行う
#InstallKeybdHook ;無条件にキーボードフックを有効にする(デバッグ用)
#InstallMouseHook ;無条件にマウスフックを有効にする(デバッグ用)
#HotkeyInterval, 2000 ;無限ループの検出間隔を設定
#MaxHotkeysPerInterval, 200 ;この回数以上のホットキーが↑の間隔で行われた場合、無限ループとして警告する
SetNumlockState,AlwaysOn ;常に NumLock 状態にして変更不可能にする
SetNumlockState, AlwaysOn ;NumLock 常にON
SetCapsLockState, AlwaysOff ;CapsLock 常にOFF
SetScrollLockState, AlwaysOff ;ScrollLock 常にOFF
;SetWinDelay, 0 ;Window操作の時間差0
DetectHiddenWindows, On ;ウィンドウ探索時に非表示になっているウィンドウを検出対象にするか

#include D:\SOFT\util\MacroCreatorPortable\_AutoHotkey\Lib\_AutoHotInterception\Lib\AutoHotInterception.ahk


;同梱monitor.ahkでキーボードのIDとスキャンコードを調べる
AHI := new AutoHotInterception() ;ライブラリ初期化
; AHI.GetDeviceId(false, 0xC0F4, 0x05C0) ;デバイス検出　マウスありtrue、キーボードのみfalse
; AHI.GetKeyboardId(0xC0F4, 0x05C0, 1) ;キーボード検出
id1 := AHI.GetKeyboardId(0xC0F4, 0x05C0, 1) ;環境設定
cm1 := AHI.CreateContextManager(id1) ;if指定用 #if cm1.IsActiveで開始
return


;----------------------------------------------------------------------------
#if cm1.IsActive

Tab::
  Reload
Return

;1by1起動
Browser_Home::Return
; Process, Exist, ahk_exe 1by1.exe ;二重起動防止用
; 	If ErrorLevel<>0
; 	{
; 		WinActivate, ahk_class 1by1WndClass ahk_exe 1by1.exe
; 		Return
; 	}
; 	Else
; 	{
; 		Run, D:\SOFT\multimedia\music\player\1by1\1by1.exe D:\, D:\SOFT\multimedia\music\player\1by1\,,PID
; 	}
; Return


;波音再生/停止
NumpadDot::^#NumpadDot


;再生 Enter
NumpadEnter::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {Space}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
; my_tooltip_function("再生/停止", 750)
Return

Space::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {Space}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

;ボリューム + -
NumpadAdd::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {NumpadAdd}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

NumpadSub::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {NumpadSub}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

;次へ
Numpad6::^+!PgUp
;Critical, On
;SetMouseDelay, -1
;Click, -641, -811 Left, 1
;ControlClick, ToolbarWindow321, ahk_exe 1by1.exe,, Left, 1,  x-642 y-815 NA
;ControlClick, ToolbarWindow321, ahk_exe 1by1.exe,, Left, 1,  x100 y45 NA
;ControlSend,, {^NumpadRight}, ahk_class 1by1WndClass
;Sleep, 10
;MouseMove, 982, 495,
;Return

;前へ
Numpad4::^+!PgDn
;Critical, On
;SetMouseDelay, -1
;Click, 100, 45 Left, 1
;Sleep, 10
;MouseMove, 982, 495,
;ControlClick, ToolbarWindow321, ahk_exe 1by1.exe,, Left, 1,  x-688 y-846 NA
;ControlSend,, {^NumpadLeft}, ahk_class 1by1WndClass
;Return

;大きく進む
Numpad3::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {NumpadRight 3}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

;大きく戻る
Numpad1::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {NumpadLeft 3}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

;最初から再生
Numpad0::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, {Enter}, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

;リピート切り替え
Backspace::
WinGet, ID, ID, ahk_exe 1by1.exe
ControlSend,, ^r, ahk_class 1by1WndClass ahk_exe 1by1.exe ahk_id %ID%
Return

;音量アップ
Numpad7::^+!/

;音量ダウン
Numpad9::^+!@



Numlock::Return
Numpad2::Return
Numpad5::Return
Numpad8::Return
NumpadDiv::Return
NumpadMult::Return
Launch_Mail::Return
Launch_App2::Return



#if

