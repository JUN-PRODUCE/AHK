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


;----------------------------------------------------------
;プロセスのコマンドラインを取得
; a::
;   WinGet, PID, PID, A
;   obj := GetCommandLine(PID, true, true)
;   MsgBox, % "CommandLine = " obj.cmd "`nImagePath = " obj.path
;   Return

GetCommandLine(PID, SetDebugPrivilege := false, GetImagePath := false)  {
   static SetDebug := 0, PROCESS_QUERY_INFORMATION := 0x400, PROCESS_VM_READ := 0x10, STATUS_SUCCESS := 0

   if (SetDebugPrivilege && !SetDebug)  {
      if !res := SeDebugPrivilege()
         SetDebug := 1
      else  {
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
   if (A_PtrSize < PtrSize)  {            ; スクリプト 32, ターゲットプロセス 64
      if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64QueryInformationProcess64", Ptr)
         failed := "NtWow64QueryInformationProcess64"
      if !ReadProcessMemory := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64ReadVirtualMemory64", Ptr)
         failed := "NtWow64ReadVirtualMemory64"
      info := 0, szPBI := 48, offsetPEB := 8
   }
   else  {
      if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtQueryInformationProcess", Ptr)
         failed := "NtQueryInformationProcess"
      ReadProcessMemory := "ReadProcessMemory"
      if (A_PtrSize > PtrSize)            ; スクリプト 64、ターゲットプロセス 32
         info := 26, szPBI := 8, offsetPEB := 0
      else                                ; スクリプトとターゲットプロセスが同じビットであること
         info := 0, szPBI := PtrSize * 6, offsetPEB := PtrSize
   }
   if failed  {
      DllCall("CloseHandle", Ptr, hProc)
      MsgBox, % failed 関数へのポインタの取得に失敗しました。
      Return
   }
   VarSetCapacity(PBI, 48, 0)
   if DllCall(QueryInformationProcess, Ptr, hProc, UInt, info, Ptr, &PBI, UInt, szPBI, UIntP, bytes) != STATUS_SUCCESS  {
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

   if (GetImagePath && obj.cmd)  {
      DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD - PtrSize*2, UShortP, szPATH, PtrType, 2, UIntP, bytes)
      DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD - PtrSize, pPtr, pPATH, PtrType, PtrSize, UIntP, bytes)

      VarSetCapacity(buff, szPATH, 0)
      DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pPATH, Ptr, &buff, PtrType, szPATH, UIntP, bytes)
      obj.path := StrGet(&buff, "UTF-16") . (IsWow64 ? " *32" : "")
   }
   DllCall("CloseHandle", Ptr, hProc)
   Return obj
}

SeDebugPrivilege()  {
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
   Return res  ; 運が良ければ0
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
