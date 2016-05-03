unit raiseImage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg;

type
  TraiseImg = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public
    procedure hideImage();
    procedure showImage();
  end;

var
  raiseImg: TraiseImg;

implementation

{$R *.dfm}

procedure TraiseImg.showImage();
begin
  if WindowState <> wsMaximized then
  begin
    Image1.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'earthwp.bmp');
    AlphaBlendValue := 0;
    Application.ProcessMessages;
    WindowState     := wsMaximized;
    timer1.Enabled  := true;
  end;
end;

procedure TraiseImg.HideImage();
begin
  WindowState   := wsNormal;
  FormStyle     := fsStayOnTop;
  timer1.Enabled := false;
end;

procedure TraiseImg.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE) ;
end;

procedure TraiseImg.Timer1Timer(Sender: TObject);
var
  increment : integer;
begin
  increment := 10;
  if ((AlphaBlendValue+increment) < 255) then
    AlphaBlendValue := AlphaBlendValue+increment
  else
  begin
    AlphaBlendValue := 255;
    Timer1.Enabled := false;
  end;
end;

procedure TraiseImg.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  HideImage;
end;

end.
