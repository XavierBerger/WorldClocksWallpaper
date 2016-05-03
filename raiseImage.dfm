object raiseImg: TraiseImg
  Left = 302
  Top = 252
  AlphaBlend = True
  BorderStyle = bsNone
  Caption = 'raiseImage'
  ClientHeight = 256
  ClientWidth = 475
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 475
    Height = 256
    Align = alClient
    Stretch = True
    OnMouseUp = Image1MouseUp
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
end
