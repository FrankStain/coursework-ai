object MForm: TMForm
  Left = 258
  Top = 237
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1055#1103#1090#1085#1072#1096#1082#1080
  ClientHeight = 300
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object P_Screen: TPanel
    Left = 300
    Top = 0
    Width = 300
    Height = 300
    Align = alClient
    TabOrder = 0
    DesignSize = (
      300
      300)
    object PB_Screen: TPaintBox
      Left = 5
      Top = 5
      Width = 290
      Height = 290
      Anchors = [akLeft, akTop, akRight, akBottom]
      Color = 12094331
      ParentColor = False
      OnMouseMove = PB_ScreenMouseMove
      OnMouseUp = PB_ScreenMouseUp
      OnPaint = PB_ScreenPaint
    end
  end
  object PC_Game: TPageControl
    Left = 0
    Top = 0
    Width = 300
    Height = 300
    ActivePage = TabSheet1
    Align = alLeft
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = #1055#1086#1083#1077
      object StaticText1: TStaticText
        Left = 0
        Top = 0
        Width = 292
        Height = 17
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvSpace
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1087#1086#1083#1103
        Color = clMenuHighlight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMenuText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 0
      end
      object GroupBox1: TGroupBox
        Left = 5
        Top = 25
        Width = 281
        Height = 86
        Caption = #1056#1072#1079#1084#1077#1088#1099
        TabOrder = 1
        object StaticText5: TStaticText
          Left = 146
          Top = 19
          Width = 42
          Height = 17
          Caption = #1042#1099#1089#1086#1090#1072
          TabOrder = 0
        end
        object StaticText6: TStaticText
          Left = 10
          Top = 19
          Width = 43
          Height = 17
          Caption = #1064#1080#1088#1080#1085#1072
          TabOrder = 1
        end
        object SE_MapY: TSpinEdit
          Left = 195
          Top = 16
          Width = 75
          Height = 22
          MaxValue = 5
          MinValue = 3
          TabOrder = 2
          Value = 3
        end
        object SE_MapX: TSpinEdit
          Left = 60
          Top = 16
          Width = 75
          Height = 22
          MaxValue = 5
          MinValue = 3
          TabOrder = 3
          Value = 3
        end
        object SetMapSizeButton: TButton
          Left = 145
          Top = 55
          Width = 125
          Height = 20
          Caption = #1054#1073#1085#1086#1074#1080#1090#1100
          TabOrder = 4
          OnClick = SetMapSizeButtonClick
        end
      end
      object GroupBox2: TGroupBox
        Left = 5
        Top = 120
        Width = 281
        Height = 146
        Caption = #1048#1075#1088#1072
        TabOrder = 2
        object FlushMapButton: TButton
          Left = 10
          Top = 20
          Width = 260
          Height = 20
          Caption = #1057#1073#1088#1086#1089#1080#1090#1100' '#1087#1086#1083#1077
          TabOrder = 0
          OnClick = FlushMapButtonClick
        end
        object ShakeMapButton: TButton
          Left = 10
          Top = 45
          Width = 260
          Height = 20
          Caption = #1055#1077#1088#1077#1084#1077#1096#1072#1090#1100' '#1092#1080#1096#1082#1080
          TabOrder = 1
          OnClick = ShakeMapButtonClick
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1048#1048' 1'
      ImageIndex = 1
      object Bevel1: TBevel
        Left = 215
        Top = 45
        Width = 75
        Height = 11
        Shape = bsTopLine
      end
      object Bevel2: TBevel
        Left = 215
        Top = 110
        Width = 75
        Height = 11
        Shape = bsTopLine
      end
      object StaticText2: TStaticText
        Left = 0
        Top = 0
        Width = 99
        Height = 17
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvSpace
        Caption = #1055#1086#1080#1089#1082' '#1074' '#1096#1080#1088#1080#1085#1091
        Color = clMenuHighlight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMenuText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 0
      end
      object B_AI1Start: TButton
        Left = 215
        Top = 20
        Width = 75
        Height = 20
        Caption = #1048#1089#1082#1072#1090#1100
        TabOrder = 1
        OnClick = B_AI1StartClick
      end
      object LB_AI1WayList: TListBox
        Left = 5
        Top = 20
        Width = 206
        Height = 246
        ItemHeight = 13
        TabOrder = 2
      end
      object B_AI1Step: TButton
        Left = 215
        Top = 85
        Width = 75
        Height = 20
        Caption = #1064#1072#1075
        TabOrder = 3
        OnClick = B_AI1StepClick
      end
      object B_AI1Reset: TButton
        Left = 215
        Top = 60
        Width = 75
        Height = 20
        Caption = #1057#1073#1088#1086#1089#1080#1090#1100
        TabOrder = 4
        OnClick = B_AI1ResetClick
      end
      object B_AI1ClearList: TButton
        Left = 215
        Top = 125
        Width = 75
        Height = 20
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100
        TabOrder = 5
        OnClick = B_AI1ClearListClick
      end
      object P_Process: TPanel
        Left = 215
        Top = 150
        Width = 75
        Height = 116
        TabOrder = 6
        Visible = False
        object Label1: TLabel
          Left = 5
          Top = 30
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = #1055#1088#1086#1081#1076#1077#1085#1086
        end
        object L_AI1SCount: TLabel
          Left = 5
          Top = 46
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0'
        end
        object Label3: TLabel
          Left = 5
          Top = 62
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = #1080#1079
        end
        object L_AI1STotal: TLabel
          Left = 5
          Top = 78
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0'
        end
        object Label2: TLabel
          Left = 5
          Top = 95
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = #1074#1072#1088#1080#1072#1085#1090#1086#1074
        end
        object StaticText7: TStaticText
          Left = 1
          Top = 1
          Width = 53
          Height = 17
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvSpace
          Caption = #1055#1086#1080#1089#1082'...'
          Color = clMenuHighlight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMenuText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          TabOrder = 0
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = #1048#1048' 2'
      ImageIndex = 2
      object StaticText3: TStaticText
        Left = 0
        Top = 0
        Width = 102
        Height = 17
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvSpace
        Caption = #1055#1086#1080#1089#1082' '#1074' '#1075#1083#1091#1073#1080#1085#1091
        Color = clMenuHighlight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMenuText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = #1048#1048' 3'
      ImageIndex = 3
      object Bevel3: TBevel
        Left = 215
        Top = 110
        Width = 75
        Height = 11
        Shape = bsTopLine
      end
      object Bevel4: TBevel
        Left = 215
        Top = 45
        Width = 75
        Height = 11
        Shape = bsTopLine
      end
      object StaticText4: TStaticText
        Left = 0
        Top = 0
        Width = 123
        Height = 17
        Align = alTop
        BevelKind = bkSoft
        BevelOuter = bvSpace
        Caption = #1055#1086#1080#1089#1082' '#1087#1086' '#1075#1088#1072#1076#1080#1077#1085#1090#1091
        Color = clMenuHighlight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMenuText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 0
      end
      object P_Process3: TPanel
        Left = 215
        Top = 150
        Width = 75
        Height = 116
        TabOrder = 1
        Visible = False
        object Label4: TLabel
          Left = 5
          Top = 30
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = #1055#1088#1086#1081#1076#1077#1085#1086
        end
        object L_AI3SCount: TLabel
          Left = 5
          Top = 46
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0'
        end
        object Label6: TLabel
          Left = 5
          Top = 62
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = #1080#1079
        end
        object L_AI3STotal: TLabel
          Left = 5
          Top = 78
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = '0'
        end
        object Label8: TLabel
          Left = 5
          Top = 95
          Width = 65
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = #1074#1072#1088#1080#1072#1085#1090#1086#1074
        end
        object StaticText8: TStaticText
          Left = 1
          Top = 1
          Width = 53
          Height = 17
          Align = alTop
          BevelKind = bkSoft
          BevelOuter = bvSpace
          Caption = #1055#1086#1080#1089#1082'...'
          Color = clMenuHighlight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMenuText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          TabOrder = 0
        end
      end
      object B_AI3ClearList: TButton
        Left = 215
        Top = 125
        Width = 75
        Height = 20
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100
        TabOrder = 2
        OnClick = B_AI3ClearListClick
      end
      object B_AI3Reset: TButton
        Left = 215
        Top = 60
        Width = 75
        Height = 20
        Caption = #1057#1073#1088#1086#1089#1080#1090#1100
        TabOrder = 3
        OnClick = B_AI3ResetClick
      end
      object B_AI3Step: TButton
        Left = 215
        Top = 85
        Width = 75
        Height = 20
        Caption = #1064#1072#1075
        TabOrder = 4
        OnClick = B_AI3StepClick
      end
      object LB_AI3WayList: TListBox
        Left = 5
        Top = 20
        Width = 206
        Height = 246
        ItemHeight = 13
        TabOrder = 5
      end
      object B_AI3Start: TButton
        Left = 215
        Top = 20
        Width = 75
        Height = 20
        Caption = #1048#1089#1082#1072#1090#1100
        TabOrder = 6
        OnClick = B_AI3StartClick
      end
    end
  end
end
