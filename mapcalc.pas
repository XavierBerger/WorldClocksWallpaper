{
 EarthWatcher Copyright © 2002 Jussi Leinonen. All rights reserved.
 Modified by Xavier Berger Copyright © 2005. All rights reserved.
}

unit mapcalc;

interface

uses
  SysUtils, Windows, Classes, Graphics, JPEG, Math, mapcalcthread, clocks;

const
  {AxisAngle is the tilt angle of Earth (23.5 degrees) in radians}
  AxisAngle = 0.4101524;
  AxisAngleSin = 0.3987491;

var
  {These global variables are effectively constants, but can't be declared as
   such because Pi is not constant but a function.}
  Pi2: Real = Pi*2;


  EarthDay: TBitmap;

function YearDaysSoFar(Date: TDateTime): Word;
function EarthPhase(Date: TDateTime): Real;
procedure CalcZenithSpot(var Longitude,Latitude: Real;
                         Time: TDateTime);
procedure CreateCombined(ZLongitude, ZLatitude: Real;
                         EarthDay, EarthCombined: TBitmap);
procedure CalcMap(EarthDayJPEG, EarthNightJPEG: TJPEGImage;
                  EarthCombined: TBitmap;
                  Time: TDateTime;
                  Width: Integer);

implementation

uses forms;

function YearDaysSoFar(Date: TDateTime): Word;
var Year, Month: Word;
    i: Integer;
begin
  {How many days have passed this year?}
  {Don't care of leap years, the difference is minimal...}
  DecodeDate(Date,Year,Month,Result);
  for i := 1 to Month-1 do
    case i of
      1,3,5,7,8,10,12: Inc(Result,31);
      4,6,9,11: Inc(Result,30);
      2: Inc(Result,28);
    end;
end;

function EarthPhase(Date: TDateTime): Real;
begin
  {The phase of earth (=season!) during its circle around the sun,
   starting with spring}
  {Note that the sun comes about 7 days "ahead" of the calendar year!}
  Result := (YearDaysSoFar(Date)-7)*((Pi2)/365)+Pi;
end;

procedure CalcZenithSpot(var Longitude,Latitude: Real;
                         Time: TDateTime);
var Hour, Min, Sec, MSec: Word;
begin
  {Calculate the spot on earth where the sun is at zenith(straight above)}
  {Yes, I'm now aware that I don't follow the standards of spherical
   coordinates; I wasn't familiar with them when I wrote this.}

  DecodeTime(Time,Hour,Min,Sec,MSec);

  {The result here is in radians,
   increasing counterclockwise as seen from above north pole.}
  Longitude := Pi2 - (((Hour*3600)+(Min*60)+Sec)/SecsPerDay)*Pi2;

  {Negative resulthere -> southern latitude}
  Latitude := ArcSin(AxisAngleSin*Cos(EarthPhase(Time)));
end;


procedure CreateCombined(ZLongitude, ZLatitude: Real;
                         EarthDay, EarthCombined: TBitmap);
var Long: Real;
    x: integer;
    {Quite a lot of variables used here...
     The point is not to have to calculate the same thing several times...}
    SinZLong, CosZLong, SinLong, CosLong, SinZLat, CosZLat: Extended;
    Height, Width, Width3: Integer;
    SinZLoCosZLa, CosZLoCosZLa: Real;
    Pi2PerWidth3: Real;
    SinLongs, CosLongs: TRealArray;
    TopThread, BottomThread: TMapCalcThread;
    RunIdle: Boolean;
begin
  {Blend the night and day images}
  Height := EarthCombined.Height;
  Width := EarthCombined.Width;
  Width3 := (Width-1)*3;
  SinCos(ZLongitude,SinZLong,CosZLong);
  SinCos(ZLatitude,SinZLat,CosZLat);
  SinZLoCosZLa := SinZLong*CosZLat;
  CosZLoCosZLa := CosZLong*CosZLat;
  Pi2PerWidth3 := (Pi2)/(Width*3);

  SetLength(SinLongs,Width3+1);
  SetLength(CosLongs,Width3+1);
  for x := 0 to Width3 do begin
    if x mod 3 = 0 then begin
      Long := Pi2PerWidth3*x;
      SinCos(Long,SinLong,CosLong);
    end;
    SinLong := SinZLoCosZLa*SinLong;
    CosLongs[x] := CosZLoCosZLa*CosLong+SinLong;
  end;

  RunIdle := (GetThreadPriority(GetCurrentThread) = THREAD_PRIORITY_IDLE);

  TopThread := TMapCalcThread.Create(RunIdle, 0, Height div 2,
                                     EarthDay, EarthCombined,
                                     Height, Width3, SinZLat, CosLongs);
  BottomThread := TMapCalcThread.Create(RunIdle, (Height div 2)+1, Height-1,
                                        EarthDay, EarthCombined,
                                        Height, Width3, SinZLat, CosLongs);

  TopThread.WaitFor;
  BottomThread.WaitFor;

  TopThread.Free;
  BottomThread.Free;

end;

procedure CalcMap(EarthDayJPEG, EarthNightJPEG: TJPEGImage;
                 EarthCombined: TBitmap;
                 Time: TDateTime;
                 Width: Integer);

var Latitude, Longitude: Real;
begin
  {Do the initial work before combining the maps}
  EarthDay := TBitmap.Create;

  EarthDay.PixelFormat := pf24bit;
  EarthDay.HandleType := bmDIB;
  EarthCombined.PixelFormat := pf24bit;
  EarthCombined.HandleType := bmDIB;

  if (EarthDayJPEG.Width <> EarthNightJPEG.Width) or
     (EarthDayJPEG.Height <> EarthNightJPEG.Height) then
    Exit;

  EarthDay.Width := Width;
  EarthDay.Height := Trunc(EarthDayJPEG.Height*Width/EarthDayJPEG.Width);
  EarthCombined.Width := EarthDay.Width;
  EarthCombined.Height := EarthDay.Height;

  EarthCombined.Canvas.StretchDraw(
    Rect(0,0,EarthCombined.Width,EarthCombined.Height),EarthNightJPEG);

  EarthDay.Canvas.StretchDraw(
    Rect(0,0,EarthDay.Width,EarthDay.Height),EarthDayJPEG);

  CalcZenithSpot(Longitude, Latitude, Time);

  CreateCombined(Longitude, Latitude, EarthDay, EarthCombined);

  EarthDay.Free;
end;

end.
