

;Explorer
#IfWinActive, ahk_class CabinetWClass ahk_exe explorer.exe
{
	;検索クリア
	Esc::
	ControlGetText, vText, WindowsForms10.BUTTON.app.0.378734a_r57_ad11, ahk_class CabinetWClass
	if (ErrorLevel <> 0)
		{
			Send, {Escape}
		}
	Else
		{
			Critical, On
			MouseGetPos, vX, vY, vhwnd
			SetMouseDelay, -1
			WinActivate, ahk_class CabinetWClass
			SendInput, {Click, 219, 119, 2} ;Rerative window
			Sleep, 45
			MouseMove, %vX%, %vY%, 0
			Critical, Off
		}
	Return

	; プロセスKill
	^d::
	Send, ^d
	vFile_Path := Explorer_GetSelection()
	; Kill_Process("wmplayer.exe")
	Loop, 3
		{
			Run, %gLockHunter%LockHunter.exe /silent /unlock %vFile_Path%, %gLockHunter%,, Hide
		}
	Return

	;現在のディレクトリでcmd実行
	^+F4::
	Critical, On
	vlipbk = %ClipboardAll%
	Clipboard =
	Send, ^+C
	Run, %gCMD%,,,
	Sleep, 50
	Send, cd{Space}
	Sleep, 10
	Send, ^v
	Sleep, 50
	Send, {Enter}
	Clipboard = %vClipbk%
	Critical, Off
	Return

	;ファイル名コピー
	^MButton::
	; ^!C::
	ControlGetFocus, myControl, A
	If (myControl = "DirectUIHWND3")
	{
		clipboard =
		SendInput, {Control Down}c{Control Up}
		ClipWait, 0
		Clipboard := RegExReplace(Clipboard, "m)^.+\\", "")
		Sort, Clipboard
	}
	Return

}
Return
#IfWinActive






;DocFetcher
#IfWinActive, ahk_exe javaw.exe
{
	^MButton::Return

	;Tumblr Edit画面
	; ^LButton::
	MButton::
	Critical, On
		Clipboard := ""
		Send, {RButton}
		Sleep, 20
		Send, t
		Sleep, 60
	if (RegExMatch(Clipboard, "tmblr"))
	{
		my_tooltip_function("● 短縮処理 開始", 950)
		;短縮URL展開
			req := ComObjCreate("WinHttp.WinHttpRequest.5.1") ;URL展開準備
			req.Open("HEAD", Clipboard) ;URL展開開始
			req.Option(6) := False ; Disable auto redirect
			req.Send()
		vUrl_Origin := req.GetResponseHeader("Location")
		RegExMatch(vUrl_Origin, "\d{5,}", vUrl_Edit) ;記事POST番号抽出
		Run, %gChrome%chrome.exe "https://www.tumblr.com/edit/dropoutsurf/%vUrl_Edit%/", %gChrome%,,
		WinActivate, ahk_class Chrome_WidgetWin_1
		Critical, Off
		Return
	}
	Else
	{ ;Tumblr Edit URLではない場合chrome検索
		my_tooltip_function("● to Chrome", 950)
		GoSub, tochrome
		Critical, Off
		Return
	}
	Critical, Off
	Return

	;chromeで開く
	tochrome:
	^+LButton::
	Clipboard := ""
	my_tooltip_function("● to Chrome", 950)
	Send, {RButton}
	Sleep, 20
	Send, t
	Sleep, 50
	Run, %gChrome%chrome.exe "%Clipboard%", %gChrome%,,
	WinActivate, ahk_class Chrome_WidgetWin_1
	Return

	;次へ
	TAB::
	ControlFocus, SysListView322, A
	ControlSend, SysListView322, {Down}, DocFetcher
	Return

	;前へ
	^+TAB::
	ControlFocus, SysListView322, A
	ControlSend, SysListView322, {Up}, DocFetcher
	Return
}
Return
#IfWInActive


;WizFile
#IfWinActive, ahk_exe WizFile64.exe
{
	; ^+q:: ;削除 Ctr+Shift+Q
	; Send, {Delete}
	; Sleep, 100
	; Send, {Enter}
	; Return

	^d::F2 ;リネーム

	;エクスプローラーで開く
	^+e::
	Send, ^e
	Return

	;拡張子別 アプリ起動
	Space::
	SetKeyDelay, -1
	Clipboard := ""
	Send, ^!c ;パスのコピー
	ClipWait, 1
	Sleep, 30
	vFullPath := RegExReplace(Clipboard, "\r\n", "") ;改行が混じるのを消す
	SplitPath Clipboard,,, vExt ;拡張子抽出
	if (RegExMatch(vExt, "i)^(zip|rar|7z|lzh)$")) {
		Run, %gMangaMeeya%MangaMeeya.exe "%vFullPath%" -f, %gMangaMeeya%,,
		Return
	}
	Else if (RegExMatch(vExt, "i)^(mp4|avi|mkv|flv|rm|mpg|mpeg)$")) {
		Run,%gVLC%vlc.exe --rate=1.5 "%vFullPath%", %gVLC%,,
		; MsgBox,,,D:\SOFT\マルチメディア\動画\VLC\vlc.exe --rate=1.5 "%Clipboard%"
		Return
	}
	Else { ;指定拡張子以外
		Sleep, 50
		Run, D:\SOFT\ユーティリティ\デスクトップ補助\QuickLook\QuickLook.exe "%Clipboard%", D:\SOFT\ユーティリティ\デスクトップ補助\QuickLook\,,
		Return
	}
	Return
}
Return
#IfWinActive
