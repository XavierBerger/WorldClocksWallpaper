object FAddClock: TFAddClock
  Left = 509
  Top = 100
  Width = 392
  Height = 491
  BorderStyle = bsSizeToolWin
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 403
    Width = 384
    Height = 61
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 34
      Height = 13
      Caption = 'Display'
    end
    object Label2: TLabel
      Left = 8
      Top = 37
      Width = 37
      Height = 13
      Caption = 'Position'
    end
    object Label3: TLabel
      Left = 164
      Top = 36
      Width = 68
      Height = 13
      Caption = 'Offset from left'
    end
    object Panel2: TPanel
      Left = 298
      Top = 0
      Width = 86
      Height = 61
      Align = alRight
      BevelOuter = bvNone
      Caption = ' '
      TabOrder = 0
      object ButtonOK: TButton
        Left = 6
        Top = 32
        Width = 75
        Height = 21
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
        OnClick = ButtonOKClick
      end
      object ButtonCancel: TButton
        Left = 6
        Top = 4
        Width = 75
        Height = 21
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
        OnClick = ButtonCancelClick
      end
    end
    object EditDisplay: TEdit
      Left = 56
      Top = 4
      Width = 237
      Height = 21
      TabOrder = 1
      OnChange = EditDisplayChange
    end
    object RadioButtonTop: TRadioButton
      Left = 56
      Top = 36
      Width = 45
      Height = 17
      Caption = 'Top'
      TabOrder = 2
      OnClick = RadioButtonTopClick
    end
    object RadioButtonBottom: TRadioButton
      Left = 100
      Top = 36
      Width = 61
      Height = 17
      Caption = 'Bottom'
      TabOrder = 3
      OnClick = RadioButtonTopClick
    end
    object SpinEditPosition: TSpinEdit
      Left = 240
      Top = 32
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = SpinEditPositionChange
    end
  end
  object ListViewTimeZone: TListView
    Left = 0
    Top = 0
    Width = 384
    Height = 403
    Align = alClient
    Checkboxes = True
    Columns = <
      item
        Caption = 'GMT'
        Width = 60
      end
      item
        Caption = 'Name'
        Width = 300
      end>
    ColumnClick = False
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ParentShowHint = False
    ShowHint = True
    SortType = stData
    TabOrder = 1
    ViewStyle = vsReport
    OnChange = ListViewTimeZoneChange
    OnClick = ListViewTimeZoneClick
    OnCompare = ListViewTimeZoneCompare
    OnInfoTip = ListViewTimeZoneInfoTip
  end
end
