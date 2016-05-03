{
 Created by Xavier Berger Copyright © 2005 under General Public License v2.
 Portion of code are coming from "Demo Program for GpTimeZone by Primoz
 Gabrijelcic modified by Ferenc Szentmiklosi almasw@elender.hu"
}
unit clocks;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Spin, IniFiles,
  gpTimezone, StdCtrls, ExtCtrls, ComCtrls;

type

  TTimeInfo = class
    private
      index        : integer;
      GMTgap       : String;
      englishName  : String;
      displayName  : String;
      Bias         : Integer;
      timeZone     : TTimeZoneInformation;
      StdBias      : Integer;
      DayBias      : Integer;
      StartDate    : TDateTime;
      EndDate      : TDateTime;
      North        : Boolean;
      city         : String;
      bottom       : boolean;
      position     : integer;
      checked      : boolean;
  end;


  TFAddClock = class(TForm)
    Panel1: TPanel;
    ListViewTimeZone: TListView;
    Panel2: TPanel;
    ButtonOK: TButton;
    EditDisplay: TEdit;
    RadioButtonTop: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    RadioButtonBottom: TRadioButton;
    SpinEditPosition: TSpinEdit;
    Label3: TLabel;
    ButtonCancel: TButton;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListViewTimeZoneCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ListViewTimeZoneChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure EditDisplayChange(Sender: TObject);
    procedure RadioButtonTopClick(Sender: TObject);
    procedure SpinEditPositionChange(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ListViewTimeZoneInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure ListViewTimeZoneClick(Sender: TObject);

  private
    loaded : boolean;
    procedure LoadTimeZones;

  end;

  procedure AddClocks(Image: TBitmap; Time : TDateTime);


var
  ClockList : TStringList;

implementation

{$R *.dfm}

uses DateUtils, main, Debug;

{-------------------------------------------------------------------------------

}
procedure LoadTimeZones;
var
  iniFile : TMemIniFile;
  RegTZ   : TGpRegistryTimeZones;
  TZ      : TTimeZoneInformation;
  p       : integer;
  i       : integer;
  sign    : string;
  EndDate     : TDateTime;
  StartDate   : TDateTime;
  StandardBias: longint;
  DaylightBias: longint;
  timeInfo : TTimeInfo;
  section : String;
begin
  try
    iniFile := TMemIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  except
    if iniFile <> nil then
      FreeAndNil(iniFile);
    Exit;
  end;

  RegTZ := TGpRegistryTimeZones.Create;

  if iniFile <> nil then
  try
    RegTZ.Reload;
    for i := 0 to regTZ.Count-1 do
    begin
      timeInfo := TTimeInfo.Create();
      timeInfo.index := i;

      TZ := RegTZ[i].TimeZone;

      timeInfo.timeZone    := TZ;
      timeInfo.englishName := RegTZ[i].EnglishName;
      timeInfo.displayName := RegTZ[i].DisplayName;

      if TZ.bias = 0 then
        timeInfo.GMTgap := ''
      else
      begin
        if TZ.bias < 0
          then sign := '+'
          else sign := '-';
        timeInfo.GMTgap := Format('%s%.2d:%.2d',[sign,Abs(TZ.bias) div 60,Abs(TZ.bias) mod 60]);
      end;
      if (timeInfo.displayName <> '') and (timeInfo.displayName[1] = '(') then begin
        // strip (GMT+xx:xx) prefix
        p := Pos(')',timeInfo.displayName);
        if p > 0 then System.Delete(timeInfo.displayName,1,p);
        while (timeInfo.displayName <> '') and (timeInfo.displayName[1] = ' ') do
          System.Delete(timeInfo.displayName,1,1);
      end;

      if GetTZDaylightSavingInfo (TZ, StartDate, EndDate, DaylightBias, StandardBias) then
      begin
        timeInfo.StdBias := TZ.Bias + TZ.StandardBias;
        timeInfo.DayBias := TZ.Bias + TZ.DaylightBias;
        timeInfo.StartDate := StartDate;
        timeInfo.EndDate := EndDate;
        timeInfo.north := EndDate > StartDate;
      end
      else
      begin
        timeInfo.StdBias := TZ.Bias;
        timeInfo.DayBias := TZ.Bias;
        timeInfo.north := false;
      end;

      case GetTimeZoneInformation(TZ) of
        TIME_ZONE_ID_STANDARD: timeInfo.Bias := RegTZ[i].TimeZone.Bias + RegTZ[i].TimeZone.StandardBias;
        TIME_ZONE_ID_DAYLIGHT: timeInfo.Bias := RegTZ[i].TimeZone.Bias + RegTZ[i].TimeZone.DaylightBias;
      else
        timeInfo.Bias := RegTZ[i].TimeZone.Bias;
      end;

      ClockList.AddObject(timeInfo.displayName,timeInfo);
    end;
    for i := 0 to ClockList.Count -1 do
    begin
      timeInfo := TTimeInfo(ClockList.Objects[i]);
      section := 'clock-'+IntToStr(timeInfo.index);
      if iniFile.SectionExists(section) then
      begin
        timeInfo.checked := true;
        timeInfo.city := IniFile.ReadString(section,'city','');
        timeInfo.bottom := IniFile.ReadBool(section,'bottom',true);
        timeInfo.position := IniFile.ReadInteger(section,'position',timeInfo.position);
      end
      else
      begin
        timeInfo.checked := false;
        timeInfo.city := timeInfo.displayName;
        timeInfo.position := Trunc(Screen.Width/2 - ((Screen.Width) / 26) * (timeInfo.StdBias / 60) - 40);
      end;
    end;
  finally
    RegTZ.free;
  end;
  inifile.free;
end;

{-------------------------------------------------------------------------------
}
procedure DrawClock(Time: TDateTime; Image: TBitmap; clockInfo : TTimeInfo);
var rect : TRect;
    diameter : integer;
    center : TPoint;
    angle : Real;
    Hour,Min,Sec,MSec: Word;
    HourInt,MinInt: Integer;
begin
  DecodeTime(Time,Hour,Min,Sec,MSec);
  HourInt := Hour;
  MinInt := Min;

  //Inc(MinInt,Bias);



  Dec(MinInt,clockInfo.Bias);
  //Dec(MinInt,clockInfo.DayBias);
  while MinInt >= 60 do begin
    Dec(MinInt,60);
    Inc(HourInt);
  end;
  while MinInt < 0 do begin
    Inc(MinInt,60);
    Dec(HourInt);
  end;
  while HourInt < 0 do
    Inc(HourInt,24);
  while HourInt >= 24 do
    Dec(HourInt,24);

  with Image.Canvas do
  begin
    Brush.Style := bsSolid;
    Pen.Style := psClear;
    Diameter := 45;

    Brush.Color := MainForm.ColorBoxClocks.Selected;

    if clockInfo.bottom then
      rect.Top := (Screen.Height-(Screen.width div 2)) div 2 + (Screen.width div 2)+3
    else
      rect.Top := (Screen.Height-(Screen.width div 2)) div 2 - 74;
    rect.Left := clockInfo.position;
    rect.Right := rect.Left+diameter;
    rect.Bottom := rect.Top+diameter;
    Ellipse(rect);

    Brush.Color := MainForm.ColorBoxBackground.Selected;
    rect.Top := rect.Top+1;
    rect.Left := rect.Left+1;
    rect.Right := rect.Right-1;
    rect.Bottom := rect.Bottom-1;
    Ellipse(rect);

    Pen.Style := psSolid;
    Pen.Color := MainForm.ColorBoxClocks.Selected;

    center.X := rect.Left + diameter div 2;
    center.Y := rect.Top + diameter div 2;
    diameter := diameter - 10;
    angle := - (3.141592 * (60 - MinInt) / 30 ) - (3.141592 /2);
    MoveTo(center.X,center.Y);
    LineTo(Center.X+trunc(diameter*cos(angle)/2), center.Y+trunc(diameter*sin(angle)/2));
    diameter := diameter - 14;
    angle := - (3.141592 * (12 - HourInt - MinInt / 60) / 6) - (3.141592 / 2);
    MoveTo(center.X,center.Y);
    LineTo(Center.X+trunc(diameter*cos(angle)/2), center.Y+trunc(diameter*sin(angle)/2));

    Font.Color := MainForm.ColorBoxClocks.Selected;
    Font.Name := 'Courier New';

    TextOut(Rect.Left + (Rect.Right - Rect.Left - TextWidth('hh:mm')) div 2, rect.Bottom + 2, Format('%0.2d:%0.2d', [HourInt,MinInt]));
    TextOut(Rect.Left + (Rect.Right - Rect.Left - TextWidth(clockInfo.city)) div 2, rect.Bottom + 14, clockInfo.city);
  end;
end;

{-------------------------------------------------------------------------------

}
procedure AddClocks(Image: TBitmap; Time : TDateTime);
var
  iloop : integer;
begin
  for iloop := 0 to ClockList.Count - 1 do
  begin
    if (TTimeInfo(ClockList.Objects[iloop]).Checked) then
    begin
      DrawClock(Time,Image,TTimeInfo(ClockList.Objects[iloop]));
    end;
  end;
end;

(*******************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************)

{-------------------------------------------------------------------------------

}
procedure TFAddClock.ButtonOKClick(Sender: TObject);
var
  iloop : integer;
  section : String;
  timeInfo : TTimeInfo;
  inifile : TInifile;
begin
  iniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'settings.ini');
  try
    for iloop := 0 to ListViewTimeZone.Items.Count -1 do
    begin
      timeInfo := TTimeInfo(ListViewTimeZone.Items.Item[iloop].Data);
      section := 'clock-'+IntToStr(timeInfo.index);
      if ListViewTimeZone.Items.Item[iloop].Checked then
      begin
        timeInfo.checked := true;
        IniFile.WriteString(section,'city',timeInfo.city);
        IniFile.WriteBool(section,'bottom',timeInfo.bottom);
        IniFile.WriteInteger(section,'position',timeInfo.position);
      end
      else
      begin
        timeInfo.checked := false;
        if inifile.SectionExists(section) then
          inifile.EraseSection(section);
      end;
    end;
    Close;
  finally
    inifile.free;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.FormCreate(Sender: TObject);
begin
  loaded := false;
  LoadTimeZones;
  loaded := true;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.LoadTimeZones;
var
  iloop : integer;
  timeInfo : TTimeInfo;
begin
  for iloop := 0 to ClockList.Count-1 do
  begin
    timeInfo := TTimeInfo(ClockList.Objects[iloop]);
    with ListViewTimeZone.Items.Add do
    begin
      Caption := timeInfo.GMTgap;
      Subitems.Add(timeInfo.displayName);
      data := timeInfo;
      Checked := timeInfo.checked;
    end;
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.ListViewTimeZoneCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  bias1, bias2: longint;
begin
  bias1 := - TTimeInfo(Item1.Data).StdBias;
  bias2 := - TTimeInfo(Item2.Data).StdBias;
  if bias1 < bias2
    then Compare := -1
  else if bias1 > bias2
    then Compare := 1
    else Compare := StrIComp(PChar(Item1.Caption),PChar(Item2.Caption));
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.ListViewTimeZoneChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  timeInfo : TTimeInfo;
begin
  if Loaded and Assigned(ListViewTimeZone.Selected) then
  begin
    timeInfo := TTimeInfo(ListViewTimeZone.Selected.data);
    if timeInfo.city <> '' then
      EditDisplay.Text := timeInfo.city
    else
      EditDisplay.Text := timeInfo.displayName;
    RadioButtonTop.Checked := not timeInfo.bottom;
    RadioButtonBottom.Checked := timeInfo.bottom;
    SpinEditPosition.Value := timeInfo.position
  end;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.EditDisplayChange(Sender: TObject);
begin
  TTimeInfo(ListViewTimeZone.Selected.data).city := EditDisplay.Text;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.RadioButtonTopClick(Sender: TObject);
begin
  TTimeInfo(ListViewTimeZone.Selected.data).bottom := RadioButtonBottom.Checked;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.SpinEditPositionChange(Sender: TObject);
begin
  TTimeInfo(ListViewTimeZone.Selected.data).position := SpinEditPosition.Value;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

{-------------------------------------------------------------------------------

}
procedure TFAddClock.ListViewTimeZoneInfoTip(Sender: TObject; Item: TListItem;
  var InfoTip: String);
var
  timeInfo : TTimeInfo;
const
  OrdNums: array [1..5] of string = ('1st', '2nd', '3rd', '4th', 'last');
begin
    timeInfo := TTimeInfo(Item.Data);
    InfoTip := Format('%s, %d minute bias',[timeInfo.englishName, timeInfo.StdBias]);
    if timeInfo.StdBias <> timeInfo.DayBias then
    begin
      if timeInfo.timeZone.StandardDate.wYear = 0 then begin //"Day of month" date
        with timeInfo.timeZone.StandardDate do begin
              InfoTip := InfoTip + #10#13 + Format('Starts on %s %s of %s at %s GMT', [
            OrdNums[wDay], LongDayNames[wDayOfWeek + 1], LongMonthNames[wMonth],
            TimeToStr(EncodeTime(wHour, wMinute, wSecond, wMilliseconds) + timeInfo.DayBias / MINUTESPERDAY)]);
        end;
      InfoTip := InfoTip + #10#13 + 'This year: '+FormatDateTime('c',timeInfo.EndDate);
      end
      else begin //Absolute date
        InfoTip := InfoTip + #10#13 + ('Absolute date: '+
          DateTimeToStr(SystemTimeToDateTime(timeInfo.timeZone.StandardDate) + timeInfo.DayBias / MINUTESPERDAY));
      end;
      InfoTip := InfoTip + #10#13 + Format('%s, %d minute bias',[timeInfo.timeZone.DaylightName, timeInfo.DayBias]);
      if timeInfo.timeZone.DaylightDate.wYear = 0 then begin //"Day of month" date
        with timeInfo.timeZone.DaylightDate do begin
          InfoTip := InfoTip + #10#13 + (Format('Starts on %s %s of %s at %s GMT', [
            OrdNums[wDay], LongDayNames[wDayOfWeek + 1], LongMonthNames[wMonth],
            TimeToStr(EncodeTime(wHour, wMinute, wSecond, wMilliseconds) + timeInfo.StdBias / MINUTESPERDAY)]));
        end;
        InfoTip := InfoTip + #10#13 + ('This year: '+FormatDateTime('c',timeInfo.StartDate));
      end
      else begin //Absolute date
        InfoTip := InfoTip + #10#13 + ('Absolute date: '+
          DateTimeToStr(SystemTimeToDateTime(timeInfo.timeZone.DaylightDate) + timeInfo.StdBias / MINUTESPERDAY));
      end;
    end;  
end;

(*******************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************)

{-------------------------------------------------------------------------------

}
procedure TFAddClock.ListViewTimeZoneClick(Sender: TObject);
var
  Item : TListItem;
begin
  Item := ListViewTimeZone.GetItemAt(ScreenToClient(Mouse.CursorPos).X,ScreenToClient(Mouse.CursorPos).Y);
  if Assigned(Item) then
    Item.Selected := true;
end;

initialization
  ClockList := TStringList.Create;
  LoadTimeZones;

{-------------------------------------------------------------------------------

}
finalization
  while ClockList.Count>0 do
  begin
    TTimeInfo(ClockList.Objects[0]).Free;
    ClockList.delete(0);
  end;
  ClockList.Free;

end.
