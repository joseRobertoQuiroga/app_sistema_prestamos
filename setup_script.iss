#define MyAppName "Sistema de Prestamos"
#define MyAppVersion "2.0.0"
#define MyAppPublisher "Roberto Quiroga"
#define MyAppExeName "prestamos_app.exe"
#define BuildPath "build\windows\x64\runner\Release"

[Setup]
AppId={{29305EFE-618D-4058-93E9-A650F48838E3}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL="https://tusitio.com"

; 🔹 Instalación local por usuario (Estándar moderno)
DefaultDirName={localappdata}\{#MyAppName}

; 🔹 Evita pedir permisos de Administrador al momento de instalar
PrivilegesRequired=lowest

DisableDirPage=no
DisableProgramGroupPage=yes
OutputDir=instalador
OutputBaseFilename=sistema_prestamos_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64

; 🔹 Habilita formalmente el desinstalador de Windows
Uninstallable=yes
UninstallDisplayIcon={app}\{#MyAppExeName}

; 🔹 Icono del instalador (debe estar en la misma carpeta que el .iss)
SetupIconFile=app_icon.ico

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear acceso directo en el escritorio"; GroupDescription:"Accesos directos"; Flags: unchecked

[Files]
; 🔹 Copia todo el contenido del build (los archivos de tu app)
Source: "{#BuildPath}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Ejecutar {#MyAppName}"; Flags: nowait postinstall skipifsilent
