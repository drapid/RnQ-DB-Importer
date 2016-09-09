object ImpForm: TImpForm
  Left = 0
  Top = 0
  Caption = 'Import base'
  ClientHeight = 415
  ClientWidth = 407
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 370
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    407
    415)
  PixelsPerInch = 96
  TextHeight = 13
  object L1: TLabel
    Left = 8
    Top = 31
    Width = 64
    Height = 13
    Caption = 'Select source'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 182
    Width = 17
    Height = 13
    Caption = 'Log'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object SrcPageCntrl: TPageControl
    Left = 8
    Top = 50
    Width = 391
    Height = 98
    ActivePage = andrqSht
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    object andrqSht: TTabSheet
      Caption = '&&RQ/R&&Q'
      DesignSize = (
        383
        70)
      object RnQDirEdt: TLabeledEdit
        Left = 3
        Top = 16
        Width = 258
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 22
        EditLabel.Height = 13
        EditLabel.Caption = 'Path'
        TabOrder = 0
        Text = 'Import.Test'
      end
      object RnQDirBtn: TButton
        Left = 267
        Top = 14
        Width = 111
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Select user directory'
        TabOrder = 1
        OnClick = RnQDirBtnClick
      end
    end
    object InfSht: TTabSheet
      Caption = 'qip infium'
      ImageIndex = 1
      DesignSize = (
        383
        70)
      object InfDirLEdit: TLabeledEdit
        Left = 3
        Top = 16
        Width = 258
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 22
        EditLabel.Height = 13
        EditLabel.Caption = 'Path'
        TabOrder = 0
        Text = 'Tests'
      end
      object InfDirBtn: TButton
        Left = 267
        Top = 14
        Width = 111
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Select user directory'
        TabOrder = 1
        OnClick = InfDirBtnClick
      end
      object UIDLEdit: TLabeledEdit
        Left = 83
        Top = 46
        Width = 121
        Height = 21
        EditLabel.Width = 43
        EditLabel.Height = 13
        EditLabel.Caption = 'Your UID'
        LabelPosition = lpLeft
        TabOrder = 2
        Text = '775454'
      end
    end
  end
  object LogText: TMemo
    Left = 0
    Top = 207
    Width = 407
    Height = 208
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Button1: TButton
    Left = 147
    Top = 152
    Width = 121
    Height = 25
    Anchors = [akTop]
    Caption = 'Process'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ImpExpGrp: TRadioGroup
    Left = 135
    Top = 2
    Width = 264
    Height = 31
    Anchors = [akTop, akRight]
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Import'
      'Export')
    TabOrder = 3
    OnClick = ImpExpGrpClick
  end
end
