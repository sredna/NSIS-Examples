Name "RequireAdmin"
Outfile "RequireAdmin.exe"
RequestExecutionLevel Admin ; Request admin rights on Vista+ (When UAC is turned on).

!include LogicLib.nsh

Function .onInit
UserInfo::GetAccountType
Pop $0
${If} $0 != "admin" ; Require admin rights on NT4+
	MessageBox MB_IconStop "Administrator rights required!"
	SetErrorLevel 740 ; ERROR_ELEVATION_REQUIRED
	Quit
${EndIf}
FunctionEnd

Page InstFiles

Section
SectionEnd
