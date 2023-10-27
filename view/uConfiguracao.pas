unit uConfiguracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, ConfiguracaoSistema;

type
  TfrmConfiguracao = class(TForm)
    gridConfig: TStringGrid;
    cbbDriverId: TComboBox;
    btnSalvar: TButton;
    procedure FormShow(Sender: TObject);
    procedure gridConfigSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure cbbDriverIdChange(Sender: TObject);
    procedure cbbDriverIdExit(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    procedure PreparaTela;
    procedure CarregaConfiguracao;
    procedure AlimentaAConfiguracao;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;

implementation

uses
  Controller.Base;

{$R *.dfm}

procedure TfrmConfiguracao.cbbDriverIdChange(Sender: TObject);
begin
  gridConfig.Cells[gridConfig.Col, gridConfig.Row] := cbbDriverId.Items[cbbDriverId.ItemIndex];
  cbbDriverId.Visible := False;
  gridConfig.SetFocus;
end;

procedure TfrmConfiguracao.cbbDriverIdExit(Sender: TObject);
begin
  gridConfig.Cells[gridConfig.Col, gridConfig.Row] := cbbDriverId.Items[cbbDriverId.ItemIndex];
  cbbDriverId.Visible := False;
  gridConfig.SetFocus;
end;

procedure TfrmConfiguracao.FormCreate(Sender: TObject);
begin
  gridConfig.DefaultRowHeight := cbbDriverId.Height;
  cbbDriverId.Visible := False;
end;

procedure TfrmConfiguracao.FormShow(Sender: TObject);
begin
  PreparaTela;
  CarregaConfiguracao;
end;

procedure TfrmConfiguracao.gridConfigSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  R: TRect;
begin
  if (ACol in[1]) then
  begin
    if not(goEditing in gridConfig.Options) then
    gridConfig.Options := gridConfig.Options +[goEditing];
  end
  else
    if goEditing in gridConfig.Options then
      gridConfig.Options := gridConfig.Options -[goEditing];

  if ((ACol = 1) and (ARow = 1)) then
  begin
    R         := gridConfig.CellRect(ACol, ARow);
    R.Left    := R.Left + gridConfig.Left;
    R.Right   := R.Right + gridConfig.Left;
    R.Top     := R.Top + gridConfig.Top;
    R.Bottom  := R.Bottom + gridConfig.Top;
    cbbDriverId.Left    := R.Left + 1;
    cbbDriverId.Top     := R.Top + 1;
    cbbDriverId.Width   := (R.Right + 1) - R.Left;
    cbbDriverId.Height  := (R.Bottom + 1) - R.Top;
    cbbDriverId.Visible := True;
    cbbDriverId.SetFocus;
  end;
  CanSelect := True;
end;

procedure TfrmConfiguracao.PreparaTela;
begin
  gridConfig.Col := 2;
  gridConfig.Row := 1;
  gridConfig.ColWidths[0] := 100;

  gridConfig.Cells[0,0] := 'Parametros';
  gridConfig.Cells[0,1] := 'DriverID';
  gridConfig.Cells[0,2] := 'Database';
  gridConfig.Cells[0,3] := 'User name';
  gridConfig.Cells[0,4] := 'Password';
  gridConfig.Cells[0,5] := 'Protocol';
  gridConfig.Cells[0,6] := 'Server';
  gridConfig.Cells[0,7] := 'Port';
  gridConfig.Cells[0,8] := 'SQLDialect';
  gridConfig.Cells[0,9] := 'CharacterSet';

  gridConfig.Cells[2,1] := 'FB';
  gridConfig.Cells[2,2] := '';
  gridConfig.Cells[2,3] := '';
  gridConfig.Cells[2,4] := '';
  gridConfig.Cells[2,5] := 'TCPIP';
  gridConfig.Cells[2,6] := 'LOCALHOST';
  gridConfig.Cells[2,7] := '3050';
  gridConfig.Cells[2,8] := '1';
  gridConfig.Cells[2,9] := 'WIN1252';

  gridConfig.Cells[1,0] := 'Valor';
  gridConfig.Cells[2,0] := 'Default';
end;

procedure TfrmConfiguracao.btnSalvarClick(Sender: TObject);
begin
  AlimentaAConfiguracao;
  GravaConfiguracaoIni;
  ControllerBase.SetConfigurationBanco;
end;

procedure TfrmConfiguracao.CarregaConfiguracao;
begin
  gridConfig.Cells[1,1] := AConfiguracao.DriverID;
  gridConfig.Cells[1,2] := AConfiguracao.Database;
  gridConfig.Cells[1,3] := AConfiguracao.User_name;
  gridConfig.Cells[1,4] := AConfiguracao.Password;
  gridConfig.Cells[1,5] := AConfiguracao.Protocol;
  gridConfig.Cells[1,6] := AConfiguracao.Server;
  gridConfig.Cells[1,7] := AConfiguracao.Port;
  gridConfig.Cells[1,8] := AConfiguracao.SQLDialect;
  gridConfig.Cells[1,9] := AConfiguracao.CharacterSet;
end;

procedure TfrmConfiguracao.AlimentaAConfiguracao;
begin
  AConfiguracao.DriverID    := gridConfig.Cells[1, 1];
  AConfiguracao.Database    := gridConfig.Cells[1, 2];
  AConfiguracao.User_name   := gridConfig.Cells[1, 3];
  AConfiguracao.Password    := gridConfig.Cells[1, 4];
  AConfiguracao.Protocol    := gridConfig.Cells[1, 5];
  AConfiguracao.Server      := gridConfig.Cells[1, 6];
  AConfiguracao.Port        := gridConfig.Cells[1, 7];
  AConfiguracao.SQLDialect  := gridConfig.Cells[1, 8];
  AConfiguracao.CharacterSet := gridConfig.Cells[1, 9];
end;

end.
