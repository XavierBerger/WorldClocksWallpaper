{
 EarthWatcher Copyright © 2002 Jussi Leinonen. All rights reserved.
}

unit mapcalcthread;

interface
uses
  Classes, Graphics, Math, SysUtils;

type
  TRealArray = array of Real;

type
  TMapCalcThread = class(TThread)
  private
    TopLine, BottomLine: Integer;
    EarthDay, EarthCombined: TBitmap;
    Height, Width3: integer;
    SinZLat: Extended;
    CosLongs: TRealArray;
  protected
    procedure Execute; override;
  public
    constructor Create(RunIdle: Boolean;
                       TopLine, BottomLine: Integer;
                       EarthDay, EarthCombined: TBitmap;
                       Height, Width3: integer;
                       SinZLat: Extended;
                       CosLongs: TRealArray);
  end;

implementation

const
  {A rather non-scientific constant to
   simulate Earth's atmosphere's bending
   effect on light that increases the area
   of sunlight}
  AtmosphereEffect = 0.15;

var PiPer2: Real = Pi/2;

constructor TMapCalcThread.Create(RunIdle: Boolean;
                                  TopLine, BottomLine: Integer;
                                  EarthDay, EarthCombined: TBitmap;
                                  Height, Width3: integer;
                                  SinZLat: Extended;
                                  CosLongs: TRealArray);
begin

  inherited Create(False);

  if RunIdle then
    Priority := tpIdle;

  Self.TopLine := TopLine;
  Self.BottomLine := BottomLine;
  Self.EarthDay := EarthDay;
  Self.EarthCombined := EarthCombined;
  Self.Height := Height;
  Self.Width3 := Width3;
  Self.SinZLat := SinZLat;
  Self.CosLongs := CosLongs;



end;


procedure TMapCalcThread.Execute;

var DayLine, CombinedLine: PByteArray;
    Lat: Real;
    SinLat, CosLat, SinZLaSinLa: Extended;
    x, y: integer;
    Alpha: Integer;
begin
  Alpha := 0;
  for y := TopLine to BottomLine do begin
    DayLine := EarthDay.ScanLine[y];
    CombinedLine := EarthCombined.ScanLine[y];

    Lat := PiPer2-(y*Pi)/Height;
    SinCos(Lat,SinLat,CosLat);
    SinZLaSinLa := SinZLat*SinLat;

    for x := 0 to Width3 do begin
      {All colors are handled similarly so the same thing can be done to
       all bytes...}
      {Alpha is the same for one pixel (three bytes) so it's only necessary
       to recalculate it every three times}
      if x mod 3 = 0 then begin

        Alpha := Ceil(
                 4*255*(
                 SinZLaSinLa+
                 CosLat*(
                 CosLongs[x]
                 )
                 +AtmosphereEffect));
      end;

      case Alpha of
        -4*255..0: Continue;
        1..255:
          CombinedLine[x] :=
            ((Alpha*(DayLine[x]-CombinedLine[x])) shr 8) + CombinedLine[x];
        else
          CombinedLine[x] := DayLine[x];
      end;
    end;
  end;

end;

end.
 