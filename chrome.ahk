;Chrome
#IfWinActive, ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe

	;クリップボード内の文字列をペーストして開く Ctl+Shift+V
	^+v::
	Haystack = "%Clipboard%"
	Needle := "http"
	If InStr(Haystack, Needle) { ;URLの場合
		Run, D:\---\GoogleChromePortable64\GoogleChromePortable.exe "%Clipboard%"
		Return
	}	Else { ;URLじゃない場合検索
		Run, https://www.google.com/search?q=%Clipboard%
	Return
	}

	;URLコピー Ctl+Shift+C
	+^c::
	Critical, On
	Send, ^l
	Sleep, 10
	Send, ^c
	Return

;	;PDF翻訳 Alt+F13
	!F13::
	Critical, On
	Clipboard := ""
	Send, ^l
	Sleep, 10
	Send, ^c
	Sleep, 50
	ClipWait, 1
		Haystack = "%Clipboard%"
		Needle := ".pdf"
		If InStr(Haystack, Needle)
			{ ;PDFの場合
			Process, Exist, python.exe ;サーバー二重起動防止用
				If ErrorLevel<>0
				{
				Return
				}
				Else
				{
				Run, cmd.exe /c "D:\---\paper2html-master\paper2html\main.py", X:\temp\pdf_cashe, Min, ;未起動ならスタート，paper_casheの場所はワーキングディレクトリ(ramディスク)
				Sleep, 2000
				Process_High("pdftoppm.exe/python.exe/cmd.exe/conhost.exe")
				}
			Run, http://localhost:5000/paper2html/convert?url=%Clipboard%
			}
			Else
			{ ;PDFじゃない場合アラート
			MsgBox, 48,　,節子それPDFちゃう,
			Return
			}
	SetTimer, close_python, -300000 ;idle 5分後にサーバー自動終了
	Return
	close_python:
	Process, Close, python.exe
	SetTimer, close_python, off
	Return

	;Chrome 翻訳 F13
	F13::
	If KeyPressed("F13")
	{
	;２回押下 キーワード翻訳
		Send, {F13 2}
		Return
	}
	Else
	{
	;１回押下 サイト翻訳
		Chrome_Translate()
		return
	}
	Return
Return
#IfWInActive
