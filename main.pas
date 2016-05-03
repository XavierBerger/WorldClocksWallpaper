{
 EarthWatcher Copyright © 2002 Jussi Leinonen. All rights reserved.
 Modified by Xavier Berger Copyright © 2005. Modifications under under General Public License v2.
}

unit main;

interface

uses
  Windows, ExtCtrls, Menus, CoolTrayIcon, StdCtrls, ComCtrls, Controls,
  Graphics, Classes, Forms, Messages, IniFiles, SysUtils, clocks, Registry,
  jpeg, ShellApi, mapcalc, Buttons, GPTimezone, Spin
  ;

type
  TMainForm = class(TForm)
    CoolTrayIcon: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    MenuItemRefreshing: TMenuItem;
    MenuItemSeparator: TMenuItem;
    MenuItemQuit: TMenuItem;
    TimerUpdate: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    CheckBoxRunAtStartup: TCheckBox;
    RadioButtonUseCurrentTime: TRadioButton;
    RadioButtonGMT: TRadioButton;
    DatePicker: TDateTimePicker;
    ButtonUpdate: TButton;
    ButtonAddClock: TButton;
    TimePicker: TDateTimePicker;
    ColorBoxClocks: TColorBox;
    ColorBoxBackground: TColorBox;
    Label3: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label4: TLabel;
    Image4: TImage;
    Optien1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxRunAtStartupClick(Sender: TObject);
    procedure CoolTrayIconDblClick(Sender: TObject);
    procedure MenuItemQuitClick(Sender: TObject);
    procedure ButtonUpdateClick(Sender: TObject);
    procedure RadioButtonUseCurrentTimeClick(Sender: TObject);
    procedure RadioButtonGMTClick(Sender: TObject);
    procedure TimerUpdateTimer(Sender: TObject);
    procedure ButtonAddClockClick(Sender: TObject);
    procedure ImageCloseClick(Sender: TObject);
    procedure MenuItemRefreshingClick(Sender: TObject);
    procedure ImageHelpClick(Sender: TObject);
    procedure ImageworldClick(Sender: TObject);
    procedure ColorBoxBackgroundChange(Sender: TObject);
    procedure ColorBoxClocksChange(Sender: TObject);
    procedure ButtonHelpClick(Sender: TObject);
    procedure CoolTrayIconClick(Sender: TObject);
    procedure Optien1Click(Sender: TObject);
  private
    EarthCombined: TBitmap;
    procedure CreateFinal();
    function AutoRunApp(const Name: string; const Enabled: Boolean = true): Boolean;
    procedure AutoSetRefreshText;
    procedure showPopup();
  Protected  
  public
    procedure CreateMap(Time: TDateTime);
    procedure move(var Message: TWMChar); message WM_NCHITTEST;
    procedure Popup(var Message: TWMChar); message WM_USER;

  end;

var
  MainForm: TMainForm;

implementation

uses raiseImage;

{$R *.DFM}

{-------------------------------------------------------------------------------

}
procedure TMainForm.move(var Message: TWMChar);
var
  point : TPoint;
begin
  point := ScreenToClient(Mouse.CursorPos);
  If (point.X < 190) and (point.Y < 20) then
    Message.Result := HTCAPTION
  else
    Message.Result := HTCLIENT;
end;


{-------------------------------------------------------------------------------

}
procedure TMainForm.FormCreate(Sender: TObject);
var Ini: TMemIniFile;
begin
  {Load settings}
  try
    Ini := TMemIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  except
    if Ini <> nil then
      FreeAndNil(Ini);
    Exit;
  end;

  if Ini <> nil then with Ini do begin
    try
      {File settings...}
      DatePicker.DateTime := NowUTC;
      TimePicker.DateTime := NowUTC;

      RadioButtonUseCurrentTime.Checked := ReadBool('File','UseCurrentTime',True);
      TimerUpdate.Enabled := ReadBool('File','EnableRefresh',true);
      ColorBoxClocks.Selected := ReadInteger('File','clockscolor',clwhite);
      ColorBoxBackground.Selected := ReadInteger('File','backgroundcolor',clblack);
      AutoSetRefreshText;
      RadioButtonGMT.Checked := not RadioButtonUseCurrentTime.Checked;
    finally
      Free;
    end;
  end;

  {See if the registry key to run at startup has been set}
  with TRegistry.Create do begin
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run',True);
      CheckBoxRunAtStartup.Checked := ValueExists(Application.Title);
    finally
      Free;
    end;
  end;

  Application.ShowMainForm:=False;

  //showPopup();
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.CreateMap(Time: TDateTime);
var
    EarthDayJPEG, EarthNightJPEG: TJPEGImage;
    Width: Integer;
begin
  {The JPEG files containing the original images}
  EarthDayJPEG := TJPEGImage.Create;
  EarthNightJPEG := TJPEGImage.Create;

  try
    EarthDayJPEG.LoadFromFile(ExtractFilePath(Application.ExeName) + 'earthday.jpg');
    EarthNightJPEG.LoadFromFile(ExtractFilePath(Application.ExeName) + 'earthnight.jpg');
  except
    CoolTrayIcon.ShowBalloonHint('Error','Unable to load map images.'+#13#10+'Please reinstall '+Application.Title,bitError,10);
    EarthDayJPEG.Free;
    EarthNightJPEG.Free;
    Exit;
  end;

  {The resulting image}
  EarthCombined := TBitmap.Create;

  Width := EarthDayJPEG.Width;

  try
    {Call the function to do the actual image processing work}
    CalcMap(EarthDayJPEG,EarthNightJPEG,EarthCombined,Time,Width);

    {Create the final image}
    CreateFinal();
  finally
    EarthDayJPEG.Free;
    EarthNightJPEG.Free;
    EarthCombined.Free;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.CreateFinal();
var FinalBm: TBitmap;
    rect : TRect;
begin
  FinalBm := TBitmap.Create;

  try
      {Set the size for the final image}
      FinalBm.Width := Screen.Width;
      FinalBm.Height := Screen.Height;

      FinalBm.Canvas.Brush.Color := ColorBoxBackground.Selected;
      FinalBm.Canvas.Brush.Style := bsSolid;
      FinalBm.Canvas.FillRect(FinalBm.Canvas.ClipRect);
      rect.Left   := 0;
      rect.Right  := Screen.Width;
      rect.Top    := (Screen.Height-(Screen.width div 2)) div 2;
      rect.Bottom := rect.Top + (Screen.width div 2);
      FinalBm.Canvas.StretchDraw(rect,EarthCombined);

      AddClocks(FinalBm, TimePicker.Time);

      FinalBm.SaveToFile(ExtractFilePath(Application.ExeName) + 'earthwp.bmp');

      {Notify windows of the changed desktop wallpaper}
      SystemParametersInfo(SPI_SETDESKWALLPAPER,0,PChar(ExtractFilePath(Application.ExeName) + 'earthwp.bmp'),SPIF_SENDWININICHANGE);
  finally
    FinalBm.Free;
  end;
end;

{-------------------------------------------------------------------------------

}
function TMainForm.AutoRunApp(const Name: string;
                              const Enabled: Boolean = true): Boolean;

const RunWhere = '\Software\Microsoft\Windows\CurrentVersion\Run';
begin
  {Set application autorun}
  Result := False;
    with TRegistry.Create do
      try
        RootKey := HKEY_CURRENT_USER;
        if OpenKey(RunWhere, true) then
          try
            if Enabled then
              WriteString(Name, ParamStr(0))
            else
              DeleteValue(Name);
            Result:= True;
          finally
            CloseKey;
             end;
      finally
        Free;
      end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.CheckBoxRunAtStartupClick(Sender: TObject);
begin
  AutoRunApp(Application.Title,CheckBoxRunAtStartup.Checked);
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.CoolTrayIconDblClick(Sender: TObject);
begin
  Show;
  CoolTrayIcon.HideTaskbarIcon;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.MenuItemQuitClick(Sender: TObject);
begin
  raiseImg.Close;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.RadioButtonUseCurrentTimeClick(Sender: TObject);
begin
  RadioButtonGMT.Checked := False;
  DatePicker.Enabled     := False;
  TimePicker.Enabled     := False;
  DatePicker.DateTime    := nowUTC;
  TimePicker.DateTime    := nowUTC;
  TimerUpdateTimer(self);
  TimerUpdate.Enabled       := true;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.RadioButtonGMTClick(Sender: TObject);
begin
  RadioButtonUseCurrentTime.Checked := False;
  DatePicker.Enabled                := True;
  TimePicker.Enabled                := True;
  TimerUpdate.Enabled               := false;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ButtonUpdateClick(Sender: TObject);
begin
  MainForm.CreateMap(TimePicker.Time);
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.TimerUpdateTimer(Sender: TObject);
var
  Hour, Min, Sec, MSec: Word;
begin
  {Run image processing with idle priority}
  DatePicker.DateTime := nowUTC;
  TimePicker.DateTime := nowUTC;
  SetThreadPriority(GetCurrentThread,THREAD_PRIORITY_IDLE);
  ButtonUpdateClick(nil); {Work as if the update button had been clicked}
  SetThreadPriority(GetCurrentThread,THREAD_PRIORITY_NORMAL);
  DecodeTime(now, Hour, Min, Sec, MSec);
  TimerUpdate.Interval := (60-Sec)*1000-MSec;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ButtonAddClockClick(Sender: TObject);
begin
  FormStyle := fsNormal;
  with TFAddClock.create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
  FormStyle := fsStayOnTop;
  Application.ProcessMessages;
  ButtonUpdateClick(Sender);
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ImageCloseClick(Sender: TObject);
var
  Ini: TMemIniFile;
begin
  Hide;
  {Write settings to an INI file}
  try
    Ini := TMemIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  except
    if Ini <> nil then
      FreeAndNil(Ini);
    Exit;
  end;

  if Ini <> nil then with Ini do
  begin
    try
      WriteBool('File','UseCurrentTime',RadioButtonUseCurrentTime.Checked);
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.MenuItemRefreshingClick(Sender: TObject);
var
  Ini : TMemIniFile;
begin
  TimerUpdate.Enabled := not TimerUpdate.Enabled;
  AutoSetRefreshText;

  try
    Ini := TMemIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  except
    if Ini <> nil then
      FreeAndNil(Ini);
    Exit;
  end;

  if Ini <> nil then with Ini do
  begin
    try
      WriteBool('File','EnableRefresh',TimerUpdate.Enabled);
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.AutoSetRefreshText;
begin
  if TimerUpdate.Enabled then
  begin
    MenuItemRefreshing.Caption := 'Disable automatic refreshing';
    TimerUpdateTimer(nil);
    ButtonUpdateClick(nil);
  end
  else
  begin
    MenuItemRefreshing.Caption := 'Enable automatic refreshing';
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ImageHelpClick(Sender: TObject);
begin
  ImageworldClick(nil);
  ShellExecute(Handle,'open',PChar(ExtractFilePath(ParamStr(0))+'worldclockswallpaper.chm'),
               nil,nil,SW_SHOWNORMAL)
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.showPopup();
begin
  CoolTrayIcon.ShowBalloonHint( 'World Clocks Wallpaper','Click on icon to add clocks of diffent places'+#10#13+'in the world on top and bottom of earth view.',bitInfo,10);
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.Popup(var Message: TWMChar);
begin
  showPopup;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ImageworldClick(Sender: TObject);
begin
{  CoolTrayIcon.ShowBalloonHint( 'Copyright © 2005 - Xavier Berger',
Application.Title + ' is freeware.'+#13#10+
'Refer to license.rtf for condition of distribution and use.'
,bitInfo,10); }
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ColorBoxBackgroundChange(Sender: TObject);
var
  Ini : TMemIniFile;
begin
  try
    Ini := TMemIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  except
    if Ini <> nil then
      FreeAndNil(Ini);
    Exit;
  end;

  if Ini <> nil then with Ini do
  begin
    try
      WriteInteger('File','backgroundcolor',ColorBoxBackground.Selected);
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ColorBoxClocksChange(Sender: TObject);
var
  Ini : TMemIniFile;
begin
  try
    Ini := TMemIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  except
    if Ini <> nil then
      FreeAndNil(Ini);
    Exit;
  end;

  if Ini <> nil then with Ini do
  begin
    try
      WriteInteger('File','clockscolor',ColorBoxClocks.Selected);
      UpdateFile;
    finally
      Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.ButtonHelpClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',PChar(ExtractFilePath(ParamStr(0))+'worldclockswallpaper.chm'),
               nil,nil,SW_SHOWNORMAL)
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.CoolTrayIconClick(Sender: TObject);
begin
  raiseImg.showimage;
end;

{-------------------------------------------------------------------------------

}
procedure TMainForm.Optien1Click(Sender: TObject);
begin
  Show;
  CoolTrayIcon.HideTaskbarIcon;
end;

end.

