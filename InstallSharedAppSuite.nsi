/*

* If you install a suite of apps rather than a single app, add one shortcut for each app in the suite.
* Don't create a product folder if your suite contains only a single shortcut. Place your shortcut in the top-level $SMPROGRAMS folder.
* Don't provide multiple shortcuts to the same app.
* Be aware that while the Apps view groups tiles and shows the folder name, this name isn't visible when a tile is pinned to the Start screen, so make your tile names sufficiently descriptive.

*/

!define APPNAME "ExampleSuite"
!define REGUINSTKEY "{3C82DD06-21E9-4602-8C2B-266AD720951B}" ; You could use APPNAME here but a GUID is guaranteed to be unique. Use guidgen.com to create your own.
!define REGUINST 'HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REGUINSTKEY}"'
Name "${APPNAME}"
Outfile "${APPNAME} setup.exe"
RequestExecutionLevel Admin
Unicode True
InstallDir "$ProgramFiles32\${APPNAME}"
InstallDirRegKey ${REGUINST} UninstallString


!define MUI_COMPONENTSPAGE_NODESC
!include MUI2.nsh
!include LogicLib.nsh
!include Sections.nsh


Var SMDir ; Start menu folder


Function .onInit
UserInfo::GetAccountType
Pop $0
${If} $0 != "admin" ; Require admin rights on WinNT4+
	MessageBox MB_IconStop "Administrator rights required!"
	SetErrorLevel 740 ; ERROR_ELEVATION_REQUIRED
	Quit
${EndIf}
FunctionEnd


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_STARTMENU 0 $SMDir
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE English


Section "-Required files"
AddSize 35
SectionIn RO
SetOutPath $InstDir
WriteUninstaller "$InstDir\Uninstall.exe"
WriteRegStr ${REGUINST} UninstallString '"$InstDir\Uninstall.exe"'
WriteRegStr ${REGUINST} DisplayName "${APPNAME}"
WriteRegStr ${REGUINST} UrlInfoAbout "http://example.com"
SectionEnd

Section "App 1" SID_A1
File "/oname=$InstDir\App1.exe" "${NSISDIR}\Contrib\UIs\default.exe"
SectionEnd

Section "App 2" SID_A2
File "/oname=$InstDir\App2.exe" "${NSISDIR}\Contrib\UIs\default.exe"
SectionEnd

Section "App 3" SID_A3
File "/oname=$InstDir\App3.exe" "${NSISDIR}\Contrib\UIs\default.exe"
SectionEnd

Section "Start menu shortcuts"
!insertmacro MUI_STARTMENU_WRITE_BEGIN 0
CreateDirectory "$SMPrograms\$SMDir"
${If} ${SectionIsSelected} ${SID_A1}
	CreateShortcut /NoWorkingDir "$SMPrograms\$SMDir\App 1.lnk" '"$InstDir\App1.exe"'
${EndIf}
${If} ${SectionIsSelected} ${SID_A2}
	CreateShortcut /NoWorkingDir "$SMPrograms\$SMDir\App 2.lnk" '"$InstDir\App2.exe"' '/ExampleParameter'
${EndIf}
${If} ${SectionIsSelected} ${SID_A3}
	CreateShortcut /NoWorkingDir "$SMPrograms\$SMDir\App 3.lnk" '"$InstDir\App3.exe"'
${EndIf}

WriteRegStr ${REGUINST} "NSIS:SMDir" $SMDir ; We need to save the start menu folder so we can remove the shortcuts in the uninstaller
!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd


Section -Uninstall
ReadRegStr $SMDir ${REGUINST} "NSIS:SMDir"
${If} $SMDir != ""
	Delete "$SMPrograms\$SMDir\App 1.lnk"
	Delete "$SMPrograms\$SMDir\App 2.lnk"
	Delete "$SMPrograms\$SMDir\App 3.lnk"
	RMDir "$SMPrograms\$SMDir"
${EndIf}

Delete "$InstDir\MyApp.exe"
Delete "$InstDir\uninstall.exe"
RMDir "$InstDir"
DeleteRegKey ${REGUINST}
SectionEnd


Function .onSelChange
StrCpy $0 0
SectionGetFlags ${SID_A1} $1
IntOp $0 $0 | $1
SectionGetFlags ${SID_A2} $1
IntOp $0 $0 | $1
SectionGetFlags ${SID_A3} $1
IntOp $0 $0 | $1
IntOp $0 $0 & ${SF_SELECTED} ; We only want to enable the next button if at least one application in the suite is selected

!if "${MUI_SYSVERSION}" >= 2.0
StrCpy $1 $mui.Button.Next
!else
GetDlgItem $1 $hwndParent 1 ; Next button
!endif
EnableWindow $1 $0
FunctionEnd
