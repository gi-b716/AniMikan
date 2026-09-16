; AniMikan installer (Inno Setup 6.3+ / 7.x).
;
; Built by .github/actions/build-windows, which passes every value below with
; /D. The defaults let you compile it by hand from the repo root:
;
;   ISCC.exe installer\animikan.iss
;
; Everything the app writes at runtime lives under %APPDATA%\Gavin\AniMikan,
; not in {app}, so upgrades and uninstalls leave user data alone. That path
; comes from CompanyName\ProductName in windows\runner\Runner.rc.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
; major.minor.patch.0 — VersionInfoVersion only accepts numbers, and a nightly
; version like 0.1.0-nightly.20260916 cannot go in there.
#ifndef AppVersionQuad
  #define AppVersionQuad "0.0.0.0"
#endif
#ifndef AppBuildDir
  #define AppBuildDir "..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\dist"
#endif
#ifndef OutputBaseFilename
  #define OutputBaseFilename "AniMikan-setup"
#endif

[Setup]
AppId={{8F3C1A52-6B4E-4C7D-9A21-5E8D2F0B7C93}
AppName=AniMikan
AppVersion={#AppVersion}
AppVerName=AniMikan {#AppVersion}
AppPublisher=Gavin
AppPublisherURL=https://github.com/gi-b716/AniMikan
AppSupportURL=https://github.com/gi-b716/AniMikan/issues
VersionInfoVersion={#AppVersionQuad}
; PrivilegesRequired=lowest + {autopf} installs per user into
; %LOCALAPPDATA%\Programs\AniMikan with no UAC prompt, which is what makes a
; silent in-app update possible. The override dialog still lets someone pick an
; all-users install into Program Files.
DefaultDirName={autopf}\AniMikan
DefaultGroupName=AniMikan
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no
OutputDir={#OutputDir}
OutputBaseFilename={#OutputBaseFilename}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\animikan.exe
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; Pick the language from the system locale and only ask when nothing matches,
; so Chinese users get a Chinese installer without an extra click.
ShowLanguageDialog=auto

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; Vendored from the Inno Setup source tree rather than the unofficial istrans
; page, because that copy is kept current with the compiler:
;   https://raw.githubusercontent.com/jrsoftware/issrc/refs/heads/main/Files/Languages/ChineseSimplified.isl
; Refresh it when a major Inno Setup version lands.
Name: "chinesesimplified"; MessagesFile: "ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; ignoreversion matters: every nightly carries the same FILEVERSION, and
; without it Inno would skip files whose version matches what is already there.
Source: "{#AppBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\AniMikan"; Filename: "{app}\animikan.exe"
Name: "{autodesktop}\AniMikan"; Filename: "{app}\animikan.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\animikan.exe"; Description: "{cm:LaunchProgram,AniMikan}"; Flags: nowait postinstall skipifsilent
