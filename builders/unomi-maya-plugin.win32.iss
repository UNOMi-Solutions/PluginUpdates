; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyGroupName "UNOMi"
#define MyAppName "UNOMi Maya Plugin"
#define MyAppVersion "0.0.1"
#define MyAppPublisher "Oomi Inc."
#define MyAppURL "https://getunomi.com/"
#define MyAppDir "UnomiLipSync"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{52F060E8-1347-4150-870B-1028F0910023}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
CreateAppDir=yes
; Prevent changing dir
DisableDirPage=yes
DisableProgramGroupPage=yes
UsePreviousAppDir=yes
; no = allow using other dir if's previously installed

; Dir is set to: `C:\ProgramData\Autodesk\ApplicationPlugins\UnomiLipSync`.
DefaultDirName={commonappdata}\Autodesk\ApplicationPlugins\{#MyAppDir}
DefaultGroupName={#MyGroupName}
LicenseFile=..\support\LICENSE.txt
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=..\output
OutputBaseFilename=UNOMi_Maya_Plugin
SetupIconFile=..\support\unomi-logo.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\dist-maya\{#MyAppDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files