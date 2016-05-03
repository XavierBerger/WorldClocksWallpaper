{
 EarthWatcher Copyright © 2002 Jussi Leinonen. All rights reserved.
 Modified by Xavier Berger Copyright © 2005. Modifications under under General Public License v2.
}

program WorldClocksWallpaper;

uses
  Forms,
  Windows,
  Messages,
  Controls,
  main in 'main.pas' {MainForm},
  mapcalc in 'mapcalc.pas',
  mapcalcthread in 'mapcalcthread.pas',
  clocks in 'clocks.pas' {FAddClock},
  GpTimezone in 'GpTimezone.pas',
  raiseImage in 'raiseImage.pas' {raiseImg};

{$R *.RES}
var
  Handle: THandle;

begin
  Handle := OpenMutex(MUTEX_ALL_ACCESS, False, 'WorldClocksWallpaper');
  if Handle = 0 then
  begin
    Handle := CreateMutex(nil, False, 'WorldClocksWallpaper');
    Application.Initialize;
    Application.Title := 'World Clocks Wallpaper';
    Application.CreateForm(TraiseImg, raiseImg);
    with raiseImg do
    begin
      height := 2;
      width  := 2;
      top    := 0;
      left   := Screen.Width - 2;
      FormStyle := fsStayOnTop;
      show();
    end;
    Application.CreateForm(TMainForm, MainForm);
    ShowWindow(Application.Handle, SW_HIDE) ;
    Application.Run;
    CloseHandle(Handle);
  end
  else
  begin
    Handle := FindWindow('TMainForm','WorldClocksWallpaper');
    SendMessage(Handle,WM_USER,0,0);
  end
end.
