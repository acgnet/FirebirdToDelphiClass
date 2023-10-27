object ControllerBase: TControllerBase
  Height = 480
  Width = 640
  object conBase: TFDConnection
    Params.Strings = (
      'Database=inova4'
      'Server=192.168.0.250'
      'Port=3054'
      'SQLDialect=1'
      'CharacterSet=WIN1252'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Protocol=TCPIP'
      'DriverID=FB')
    LoginPrompt = False
    Left = 264
    Top = 104
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 176
    Top = 264
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 320
    Top = 264
  end
end
