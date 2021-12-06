;KeyPressed ver 1.0
;
;一定時間内にそのキーが押されたかどうかを返す
;押されれば1,押されなければ0を返す
;デフォルトは300ミリ秒
;
;押されない時は待ち時間分動作が止まるので
;ダブルクリックのようなことに使う場合、
;シングルクリックしかしなかった時に動作が遅くなる
;シングルクリック動作をキャンセルしなくてよく、押した瞬間さっさと
;動いて欲しければDoubleActionを使う
KeyPressed(key, waitMs = 190)
{
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
return result
}

;----------------------------------------------------------

; my_tooltip_function("テキスト", 500)
my_tooltip_function(str, delay) {
  ToolTip, %str% ;表示テキスト内容。””で囲む。
  SetTimer, remove_tooltip, -%delay%
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
