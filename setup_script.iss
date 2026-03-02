#define MyAppName "Sistema de Prestamos"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Roberto Quiroga"
#define MyAppExeName "prestamos_app.exe"
#define BuildPath "build\windows\x64\runner\Release"

[Setup]
AppId={{29305EFE-618D-4058-93E9-A650F48838E3}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL="https://tusitio.com"
DefaultDirName={commonpf}\{#MyAppName}
DisableDirPage=no
DisableProgramGroupPage=yes
OutputDir=instalador
OutputBaseFilename=sistema_prestamos_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}

; 🔵 ICONO DEL INSTALADOR
SetupIconFile=app_icon.ico

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear acceso directo en el escritorio"; Flags: unchecked

[Files]
; Copia todo el build
Source: "{#BuildPath}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; Crear carpeta de datos del usuario DENTRO de la carpeta de la app para PORTABILIDAD
Source: "{#BuildPath}\data\*"; DestDir: "{app}\data"; Flags: onlyifdoesntexist recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Ejecutar {#MyAppName}"; Flags: nowait postinstall skipifsilent