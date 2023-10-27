object ControllerTabela: TControllerTabela
  Height = 289
  Width = 417
  object fdqTabela: TFDQuery
    Connection = ControllerBase.conBase
    SQL.Strings = (
      'SELECT RDB$RELATION_NAME AS TABELA FROM RDB$RELATIONS'
      'WHERE RDB$SYSTEM_FLAG = 0'
      'ORDER BY 1')
    Left = 184
    Top = 112
    object fdqTabelaTABELA: TStringField
      FieldName = 'TABELA'
      Origin = 'RDB$RELATION_NAME'
      FixedChar = True
      Size = 63
    end
  end
end
