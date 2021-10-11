object Form1: TForm1
  Left = 217
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Plouf Plouf'
  ClientHeight = 529
  ClientWidth = 658
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 377
    Height = 305
    AutoSize = True
    OnMouseDown = Image1MouseDown
    OnMouseMove = Image1MouseMove
    OnMouseUp = Image1MouseUp
  end
  object Label1: TLabel
    Left = 8
    Top = 504
    Width = 66
    Height = 16
    Caption = 'Puissance:'
  end
  object BtnQuit: TButton
    Left = 496
    Top = 496
    Width = 153
    Height = 25
    Caption = 'Exit'
    TabOrder = 0
    OnClick = BtnQuitClick
  end
  object SEforce: TSpinEdit
    Left = 88
    Top = 496
    Width = 81
    Height = 26
    Increment = 100
    MaxValue = 5000
    MinValue = 200
    TabOrder = 1
    Value = 1000
    OnChange = SEforceChange
  end
  object BtnTsunami: TButton
    Left = 183
    Top = 496
    Width = 106
    Height = 25
    Caption = 'Tsunami'
    TabOrder = 2
    OnClick = BtnTsunamiClick
  end
  object CBVagues: TCheckBox
    Left = 304
    Top = 496
    Width = 185
    Height = 23
    Caption = 'affiche le buffer de vagues'
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 3
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 25
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
end
