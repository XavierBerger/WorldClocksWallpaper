; -- WorldClockWallpaper_with_sources.iss --
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
OutputBaseFilename=WorldClocksWallpaper_With_Sources
LicenseFile=license.rtf
WizardImageFile=WizModernImage-IS.bmp
WizardSmallImageFile=WizModernSmallImage-IS.bmp
AppContact=worldclockswallpaper@free.fr
AppPublisher=Xavier Berger
AppPublisherURL=http://worldclockswallpaper.free.fr/
AppVersion=1.0

[Components]
Name: "Program"; Description: "Program Files"; Types: full compact custom; Flags: fixed
Name: "Sources";  Description: "Sources of Program for Delphi 6, innoSetup and HelpMaker"; Types: full custom

[Files]
Source: "WorldClocksWallpaper.exe"; DestDir: "{app}"; Components: Program
Source: "WorldClocksWallpaper.chm"; DestDir: "{app}"; Components: Program
Source: "settings.ini"; DestDir: "{app}"; Components: Program; Flags: onlyifdoesntexist uninsneveruninstall
Source: "license.rtf"; DestDir: "{app}"; Components: Program
Source: "earthday.jpg"; DestDir: "{app}"; Components: Program
Source: "earthnight.jpg"; DestDir: "{app}"; Components: Program

Source: "WizModernImage-IS.bmp"; DestDir: "{app}\sources"; Components: Sources
Source: "WizModernSmallImage-IS.bmp"; DestDir: "{app}\sources"; Components: Sources
Source: "esbdates.zip"; DestDir: "{app}\sources"; Components: Sources
Source: "trayicon.zip"; DestDir: "{app}\sources"; Components: Sources
Source: "background.bmp"; DestDir: "{app}\sources"; Components: Sources
Source: "button_close.bmp"; DestDir: "{app}\sources"; Components: Sources
Source: "button_help.bmp"; DestDir: "{app}\sources"; Components: Sources
Source: "worldimage.bmp"; DestDir: "{app}\sources"; Components: Sources
Source: "clocks.dfm"; DestDir: "{app}\sources"; Components: Sources
Source: "clocks.pas"; DestDir: "{app}\sources"; Components: Sources
Source: "raiseImage.dfm"; DestDir: "{app}\sources"; Components: Sources
Source: "raiseImage.pas"; DestDir: "{app}\sources"; Components: Sources
Source: "earthday.jpg"; DestDir: "{app}\sources"; Components: Sources
Source: "earthnight.jpg"; DestDir: "{app}\sources"; Components: Sources
Source: "icon.ico"; DestDir: "{app}\sources"; Components: Sources
Source: "license.rtf"; DestDir: "{app}\sources"; Components: Sources
Source: "main.dfm"; DestDir: "{app}\sources"; Components: Sources
Source: "main.pas"; DestDir: "{app}\sources"; Components: Sources
Source: "mapcalc.pas"; DestDir: "{app}\sources"; Components: Sources
Source: "mapcalcthread.pas"; DestDir: "{app}\sources"; Components: Sources
Source: "settings.ini"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper.iss"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper_with_sources.iss"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper.cfg"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper.dof"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper.dpr"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper.dsk"; DestDir: "{app}\sources"; Components: Sources
Source: "WorldClocksWallpaper.res"; DestDir: "{app}\sources"; Components: Sources

Source: "worldclockswallpaper.sh5"; DestDir: "{app}\sources"; Components: Sources

[Icons]
Name: "{group}\World Clocks Wallpaper"; Filename: "{app}\WorldClocksWallpaper.exe"
Name: "{group}\License"; Filename: "{app}\license.rtf"

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run\"; ValueType: string; ValueName: "World Clocks Wallpaper"; ValueData: "{app}\WorldClocksWallpaper.exe"; Flags: uninsdeletevalue;

[Run]
Filename: "{app}\WorldClocksWallpaper.exe"; Description: "Launch application"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
Type: filesandordirs ; Name: "{app}"
