unit ConfiguracaoSistema;

interface
Uses
System.IniFiles;

type TConfiguracao = record
  DriverID,
  Database,
  User_name,
  Password,
  Protocol,
  Server,
  Port,
  SQLDialect,
  CharacterSet: string;
end;

procedure CarregaConfiguracaoIni;
procedure GravaConfiguracaoIni;

Var
  AConfiguracao: TConfiguracao;

implementation

uses
  System.SysUtils, Vcl.Forms;

procedure CarregaConfiguracaoIni;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Extractfiledir(Application.ExeName) + '\Configuracao.ini');
  try
    AConfiguracao.DriverID 		  := Ini.ReadString('CONFIGURACAO', 'DriverID' 		, 'FB');
    AConfiguracao.Database 		  := Ini.ReadString('CONFIGURACAO', 'Database' 		, 'NomeBanco');
    AConfiguracao.User_name 	  := Ini.ReadString('CONFIGURACAO', 'User_name' 	, 'SYSDBA');
    AConfiguracao.Password 		  := Ini.ReadString('CONFIGURACAO', 'Password' 		, 'masterkey');
    AConfiguracao.Protocol 		  := Ini.ReadString('CONFIGURACAO', 'Protocol' 		, 'TCPIP');
    AConfiguracao.Server 		    := Ini.ReadString('CONFIGURACAO', 'Server' 		  , 'localhost');
    AConfiguracao.Port 			    := Ini.ReadString('CONFIGURACAO', 'Port' 			  , '3050');
    AConfiguracao.SQLDialect 	  := Ini.ReadString('CONFIGURACAO', 'SQLDialect' 	, '1');
    AConfiguracao.CharacterSet 	:= Ini.ReadString('CONFIGURACAO', 'CharacterSet', 'WIN1252');

  finally
    FreeAndNil(Ini);
  end;
end;


procedure GravaConfiguracaoIni;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Extractfiledir(Application.ExeName) + '\Configuracao.ini');
  try
    Ini.WriteString('CONFIGURACAO', 'DriverID' 		, AConfiguracao.DriverID);
    Ini.WriteString('CONFIGURACAO', 'Database' 		, AConfiguracao.Database);
    Ini.WriteString('CONFIGURACAO', 'User_name' 	, AConfiguracao.User_name);
    Ini.WriteString('CONFIGURACAO', 'Password' 		, AConfiguracao.Password);
    Ini.WriteString('CONFIGURACAO', 'Protocol' 		, AConfiguracao.Protocol);
    Ini.WriteString('CONFIGURACAO', 'Server' 		  , AConfiguracao.Server);
    Ini.WriteString('CONFIGURACAO', 'Port' 			  , AConfiguracao.Port);
    Ini.WriteString('CONFIGURACAO', 'SQLDialect' 	, AConfiguracao.SQLDialect);
    Ini.WriteString('CONFIGURACAO', 'CharacterSet', AConfiguracao.CharacterSet);
  finally
    FreeAndNil(Ini);
  end;
end;




end.

