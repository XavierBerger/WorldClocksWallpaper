; -- WorldClockWallpaper.iss --
[Setup]
AppName=World Clocks Wallpaper
AppVerName=World Clocks Wallpaper
DefaultDirName={pf}\WorldClocksWallpaper
DefaultGroupName=World Clocks Wallpaper
Uninstallable=true
Compression=lzma
SolidCompression=yes
AppMutex=WorldClocksWallpaper
OutputDir=..\website
OutputBaseFilename=WorldClocksWallpaper_Install
LicenseFile=license.rtf
WizardImageFile=WizModernImage-IS.bmp
WizardSmallImageFile=WizModernSmallImage-IS.bmp
AppContact=worldclockswallpaper@free.fr
AppPublisher=Xavier Berger
AppPublisherURL=http://worldclockswallpaper.free.fr/
AppVersion=1.5

[Files]
Source: "WorldClocksWallpaper.exe"; DestDir: "{app}"
Source: "WorldClocksWallpaper.chm"; DestDir: "{app}"
Source: "settings.ini"; DestDir: "{app}"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "license.rtf"; DestDir: "{app}"
Source: "earthday.jpg"; DestDir: "{app}"
Source: "earthnight.jpg"; DestDir: "{app}"

[Icons]
Name: "{group}\World Clocks Wallpaper"; Filename: "{app}\WorldClocksWallpaper.exe"
Name: "{group}\License"; Filename: "{app}\license.rtf"

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run\"; ValueType: string; ValueName: "World Clocks Wallpaper"; ValueData: "{app}\WorldClocksWallpaper.exe"; Flags: uninsdeletevalue;

[Run]
Filename: "{app}\WorldClocksWallpaper.exe"; Description: "Launch application"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
Type: filesandordirs ; Name: "{app}"
