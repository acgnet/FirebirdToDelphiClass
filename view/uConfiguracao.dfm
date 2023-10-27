object frmConfiguracao: TfrmConfiguracao
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Configura'#231#227'o do banco de dados'
  ClientHeight = 522
  ClientWidth = 678
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object gridConfig: TStringGrid
    Left = 8
    Top = 8
    Width = 649
    Height = 457
    ColCount = 3
    RowCount = 10
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowDefAlign]
    TabOrder = 0
    OnSelectCell = gridConfigSelectCell
    ColWidths = (
      64
      321
      146)
  end
  object cbbDriverId: TComboBox
    Left = 168
    Top = 336
    Width = 201
    Height = 23
    ItemIndex = 0
    TabOrder = 1
    Text = 'FB'
    OnChange = cbbDriverIdChange
    OnExit = cbbDriverIdExit
    Items.Strings = (
      'FB'
      'IB'
      'IBLite'
      'Infx'
      'Mongo'
      'MSAcc'
      'MSSQL'
      'MySQL')
  end
  object btnSalvar: TButton
    Left = 544
    Top = 473
    Width = 113
    Height = 41
    Caption = 'Salvar'
    TabOrder = 2
    OnClick = btnSalvarClick
  end
end
