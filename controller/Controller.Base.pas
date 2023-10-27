unit Controller.Base;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Phys.IBBase, FireDAC.Comp.UI,
  Data.DB, FireDAC.Comp.Client, ConfiguracaoSistema;

type
  TControllerBase = class(TDataModule)
    conBase: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetConfigurationBanco;
  end;

var
  ControllerBase: TControllerBase;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TControllerBase }

procedure TControllerBase.SetConfigurationBanco;
begin
  with conBase do
  begin
    Params.Clear;
    Params.Values['DriverID']     := AConfiguracao.DriverID;
    Params.Values['Database']     := AConfiguracao.Database;
    Params.Values['User_name']    := AConfiguracao.User_name;
    Params.Values['Password']     := AConfiguracao.Password;
    Params.Values['Protocol']     := AConfiguracao.Protocol;
    Params.Values['Server']       := AConfiguracao.Server;
    Params.Values['Port']         := AConfiguracao.Port;
    Params.Values['SQLDialect']   := AConfiguracao.SqlDialect;
    Params.Values['CharacterSet'] := AConfiguracao.CharacterSet;
    Connected := True;
  end;
end;

end.
