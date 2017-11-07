OutFile test.exe
Name "EM_STREAMIN demo (NSIS ${NSIS_VERSION}:${NSIS_PTR_SIZE}:${NSIS_CHAR_SIZE})"
RequestExecutionLevel user

!include nsDialogs.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!define /IfNDef SF_TEXT 1
!define /IfNDef SF_RTF 2
!define /IfNDef EM_STREAMIN 1097
!define /IfNDef EM_EXLIMITTEXT 1077
!define /IfNDef SYSSTRUCT_EDITSTREAM (i,i,i)
!if "${NSIS_PTR_SIZE}" > 4
	!define /ReDef SYSSTRUCT_EDITSTREAM (p,l,p) ; 'l' is "wrong" but required to align the next pointer
!endif


Function RicheditStreamInFile ; NSIS 3 adaptation of //forums.winamp.com/showthread.php?t=288129
System::Store S
Pop $9 ; Path
Pop $8 ; SF_*
Pop $7 ; HWND
SendMessage $7 ${EM_EXLIMITTEXT} 0 0x7fffffff
FileOpen $5 "$9" r
System::Get '(p,i.R2,i.R3,i.R4)ir4r1'
Pop $2 ; EDITSTREAMCALLBACK kallback
System::Call '*${SYSSTRUCT_EDITSTREAM}(,0,kr2r6)p.r3' ; Allocate and initialize EDITSTREAM
!if "${NSIS_PTR_SIZE}" > 4
${If} $6 Z= 0
	MessageBox MB_IconStop "Callbacks not supported!"
	Quit
${EndIf}
!endif
System::Call 'USER32::SendMessage(pr7,i${EM_STREAMIN},p$8,pr3)p.r1' ; Must use System::Call and not plain SendMessage!
loop:
	StrCpy $4 $1 8
	StrCmp $4 "callback" 0 done
	System::Call 'KERNEL32::ReadFile(pr5,pR2,iR3,pR4,p0)i.r4'
	IntOp $4 $4 ! # kallback's return value (ReadFile BOOL --> ERROR_SUCCES)
	System::Call "$2"
	Goto loop 
done:
System::Free $3 ; EDITSTREAM
System::Free $2 ; EDITSTREAMCALLBACK
FileClose $5
System::Store L
FunctionEnd
!macro RicheditStreamInFile HWND Type FilePath
Push ${HWND}
Push ${Type}
Push "${FilePath}"
Call RicheditStreamInFile
!macroend

Function .onGuiInit
InitPluginsDir
File "/oname=$PluginsDir\License.txt" "${__FILE__}"
FileOpen $0 "$PluginsDir\License.rtf" W
FileWrite $0 "{\rtf1\ansi{\fonttbl\f0\fswiss Helvetica;}{\colortbl;\red0\green0\blue0;\red255\green0\blue0;\red9\green199\blue9;}\f0\pard"
FileWrite $0 "{\b\cf3 RTF}\par\par\par\par{\plain\i\cf2\fs60 Demo}\plain\par\par\par\sub EOF}"
FileClose $0
FunctionEnd

Function OnLicensePageShow
FindWindow $0 "#32770" "" $hWndParent ; Find the inner dialog
GetDlgItem $0 $0 0x3E8 ; Find the Richedit control
!insertmacro RicheditStreamInFile $0 ${SF_TEXT} "$PluginsDir\License.txt"
FunctionEnd

!ifdef NSD_CreateRichEdit
Function CustomPageCreate
nsDialogs::Create 1018
Pop $0
${NSD_CreateRichEdit} 1 1 -2 -2 ""
Pop $0
!insertmacro RicheditStreamInFile $0 ${SF_RTF} "$PluginsDir\License.rtf"
${NSD_Edit_SetReadOnly} $0 1
nsDialogs::Show
FunctionEnd
!endif

Caption "$(^Name)"
SubCaption 0 " "
Page License "" OnLicensePageShow
!ifdef NSD_CreateRichEdit
LicenseText "$(^Name)" "$(^NextBtn)"
Page Custom CustomPageCreate
!pragma warning disable 8000 ; "Page instfiles not used"
!else
LicenseText "$(^Name)" "$(^CloseBtn)"
Page InstFiles
!endif

Section
Quit
SectionEnd
