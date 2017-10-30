/*

Tips:
=====
* Don't write to shared areas ($ProgramFiles, $WinDir, Registry\HKLM, Registry\HKCR etc)

*/

!define APPNAME "ExampleApp"
!define REGUINSTKEY "{2C82DD06-21E9-4602-8C2B-266AD720951B}" ; You could use APPNAME here but a GUID is guaranteed to be unique. Use guidgen.com to create your own.
!define REGUINST 'HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${REGUINSTKEY}"'
Name "${APPNAME}"
Outfile "${APPNAME} setup.exe"
RequestExecutionLevel User
Unicode True
#InstallDir ; Not used, we determine the default in .onInit
InstallDirRegKey ${REGUINST} UninstallString


!define MUI_COMPONENTSPAGE_NODESC
!include MUI2.nsh
!include LogicLib.nsh
!define /IfNDef SHPPFW_DIRCREATE 0x01
!define /IfNDef KF_FLAG_CREATE 0x00008000
!define /IfNDef FOLDERID_UserProgramFiles {5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}


Function .onInit
StrCpy $0 "$LocalAppData\Programs" ; Default $InstDir (UserProgramFiles is %LOCALAPPDATA%\Programs by default, so we use that as our default)

${If} $InstDir == "" ; Make sure we don't overwrite $Instdir if specified on the command line or from InstallDirRegKey
	System::Call 'SHELL32::SHGetKnownFolderPath(g "${FOLDERID_UserProgramFiles}", i ${KF_FLAG_CREATE}, p 0, *p .r2)i.r1' ; This will only work on Win7+
	${If} $1 == 0
		System::Call '*$2(&w${NSIS_MAX_STRLEN} .r1)'
		System::Call 'OLE32::CoTaskMemFree(p r2)'
		StrCpy $0 $1
	${EndIf}

	StrCpy $InstDir "$0\${APPNAME}"
${EndIf}
FunctionEnd


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE English


Section "Required files"
SectionIn RO
System::Call 'SHELL32::SHPathPrepareForWrite(p $hwndParent, p 0, t d, i ${SHPPFW_DIRCREATE})'
SetOutPath $InstDir
WriteUninstaller "$InstDir\Uninstall.exe"
WriteRegStr ${REGUINST} UninstallString '"$InstDir\Uninstall.exe"'
WriteRegStr ${REGUINST} DisplayName "${APPNAME}"
WriteRegStr ${REGUINST} UrlInfoAbout "http://example.com"

File "/oname=$InstDir\MyApp.exe" "${NSISDIR}\Contrib\UIs\default.exe" ; Using default.exe as example application
SectionEnd
 
Section "Start menu shortcut"
CreateShortcut /NoWorkingDir "$SMPrograms\${APPNAME}.lnk" '"$Instdir\MyApp.exe"'
SectionEnd


Section -Uninstall
Delete "$SMPrograms\${APPNAME}.lnk"

Delete "$InstDir\MyApp.exe"
Delete "$InstDir\uninstall.exe"
RMDir "$InstDir"
DeleteRegKey ${REGUINST}
SectionEnd
