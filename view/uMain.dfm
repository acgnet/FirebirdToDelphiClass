object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Firebird do delphi class'
  ClientHeight = 659
  ClientWidth = 954
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 217
    Height = 659
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'pnl1'
    TabOrder = 0
    object dbgTabela: TDBGrid
      Left = 0
      Top = 0
      Width = 217
      Height = 659
      Align = alClient
      DataSource = dtsTabela
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgTabelaCellClick
      OnKeyDown = dbgTabelaKeyDown
      OnKeyPress = dbgTabelaKeyPress
      Columns = <
        item
          Expanded = False
          FieldName = 'TABELA'
          Width = 170
          Visible = True
        end>
    end
  end
  object pnl2: TPanel
    Left = 217
    Top = 0
    Width = 737
    Height = 659
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnl2'
    TabOrder = 1
    object pnl3: TPanel
      Left = 552
      Top = 0
      Width = 185
      Height = 659
      Align = alRight
      TabOrder = 0
      object lblMensagem: TLabel
        Left = 1
        Top = 121
        Width = 183
        Height = 497
        Align = alClient
        Alignment = taCenter
        Caption = 'lblMensagem'
        ExplicitLeft = 72
        ExplicitTop = 304
        ExplicitWidth = 72
        ExplicitHeight = 15
      end
      object btnSair: TButton
        Left = 1
        Top = 618
        Width = 183
        Height = 40
        Align = alBottom
        Caption = 'Sair'
        TabOrder = 0
        OnClick = btnSairClick
      end
      object btnGerarClasse: TButton
        Left = 1
        Top = 41
        Width = 183
        Height = 40
        Align = alTop
        Caption = 'Gerar Classe'
        TabOrder = 1
        OnClick = btnGerarClasseClick
      end
      object btnConfigurar: TButton
        Left = 1
        Top = 1
        Width = 183
        Height = 40
        Align = alTop
        Caption = 'Configurar'
        TabOrder = 2
        OnClick = btnConfigurarClick
      end
      object btnClipboard: TButton
        Left = 1
        Top = 81
        Width = 183
        Height = 40
        Align = alTop
        Caption = 'Copiar Clipboard'
        TabOrder = 3
        OnClick = btnClipboardClick
      end
    end
    object mmoClasse: TMemo
      Left = 0
      Top = 0
      Width = 552
      Height = 659
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object dtsTabela: TDataSource
    DataSet = ControllerTabela.fdqTabela
    Left = 329
    Top = 240
  end
end
