object Form1: TForm1
  Left = 192
  Top = 114
  Width = 423
  Height = 323
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 385
    Height = 33
    Alignment = taCenter
    AutoSize = False
    Caption = 'Enter a positive integer, then move to next control to validate.'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 16
    Top = 104
    Width = 385
    Height = 33
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'Enter a positive real number, then move to next control to valid' +
      'ate.'
    WordWrap = True
  end
  object O32FlexEdit1: TO32FlexEdit
    Left = 168
    Top = 56
    Width = 81
    Height = 21
    EfColors.Disabled.BackColor = clWindow
    EfColors.Disabled.TextColor = clGrayText
    EfColors.Error.BackColor = clRed
    EfColors.Error.TextColor = clBlack
    EfColors.Highlight.BackColor = clHighlight
    EfColors.Highlight.TextColor = clHighlightText
    TabOrder = 0
    Validation.BeepOnError = True
    Validation.SoftValidation = False
    Validation.ValidationEvent = veOnExit
    Validation.ValidatorType = 'None'
    Validation.ValidationType = vtUser
    Validation.InputRequired = False
    OnUserValidation = O32FlexEdit1UserValidation
    OnValidationError = O32FlexEditValidationError
  end
  object O32FlexEdit2: TO32FlexEdit
    Left = 168
    Top = 136
    Width = 81
    Height = 21
    EfColors.Disabled.BackColor = clWindow
    EfColors.Disabled.TextColor = clGrayText
    EfColors.Error.BackColor = clRed
    EfColors.Error.TextColor = clBlack
    EfColors.Highlight.BackColor = clHighlight
    EfColors.Highlight.TextColor = clHighlightText
    TabOrder = 1
    Validation.BeepOnError = True
    Validation.SoftValidation = False
    Validation.ValidationEvent = veOnExit
    Validation.ValidatorType = 'None'
    Validation.ValidationType = vtUser
    Validation.InputRequired = False
    OnUserValidation = O32FlexEdit2UserValidation
    OnValidationError = O32FlexEditValidationError
  end
end
