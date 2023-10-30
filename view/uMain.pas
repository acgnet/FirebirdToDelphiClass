unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, vcl.Clipbrd;

type
  TfrmMain = class(TForm)
    pnl1: TPanel;
    pnl2: TPanel;
    pnl3: TPanel;
    btnSair: TButton;
    btnGerarClasse: TButton;
    btnConfigurar: TButton;
    dtsTabela: TDataSource;
    dbgTabela: TDBGrid;
    btnClipboard: TButton;
    lblMensagem: TLabel;
    Panel1: TPanel;
    mmoClasse: TMemo;
    mmoController: TMemo;
    spl1: TSplitter;
    procedure btnConfigurarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnGerarClasseClick(Sender: TObject);
    procedure btnClipboardClick(Sender: TObject);
    procedure dbgTabelaKeyPress(Sender: TObject; var Key: Char);
    procedure dbgTabelaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure dbgTabelaCellClick(Column: TColumn);
    procedure btnSairClick(Sender: TObject);
  private
    { Private declarations }
    ABusca: string;
    procedure LimpaMensagem;

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uConfiguracao, ConfiguracaoSistema, Controller.Base, Controller.Tabela;

{$R *.dfm}

procedure TfrmMain.btnClipboardClick(Sender: TObject);
begin
  Clipboard.AsText := mmoClasse.Lines.Text;
  lblMensagem.Caption := 'Copiado!';
end;

procedure TfrmMain.btnConfigurarClick(Sender: TObject);
begin
  frmConfiguracao.ShowModal;
end;

procedure TfrmMain.btnGerarClasseClick(Sender: TObject);
begin
   if Trim(dtsTabela.DataSet.FieldByName('Tabela').AsString) <> EmptyStr then
   begin
    ControllerTabela.GeraClasse(mmoClasse, dtsTabela.DataSet.FieldByName('Tabela').AsString);
    ControllerTabela.GeraController(mmoController, dtsTabela.DataSet.FieldByName('Tabela').AsString);
   end;
end;

procedure TfrmMain.btnSairClick(Sender: TObject);
begin
  self.close;
end;

procedure TfrmMain.dbgTabelaCellClick(Column: TColumn);
begin
  LimpaMensagem;
end;

procedure TfrmMain.dbgTabelaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    40, 38:
    begin
      ABusca := EmptyStr;
      LimpaMensagem;
    end;
  end;
end;

procedure TfrmMain.dbgTabelaKeyPress(Sender: TObject; var Key: Char);
begin
  case key of
    #8: ABusca := EmptyStr;
    else
      ABusca := ABusca + Key;
  end;

  ControllerTabela.fdqTabela.Locate('TABELA', ABusca, [loPartialKey, loCaseInsensitive]);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  LimpaMensagem;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  CarregaConfiguracaoIni;

  if AConfiguracao.DriverID <> EmptyStr then
    ControllerBase.SetConfigurationBanco;


  if ControllerBase.conBase.Connected then
  begin
    ControllerTabela.fdqTabela.Open;
    ControllerTabela.fdqTabela.FetchAll;
  end;
end;

procedure TfrmMain.LimpaMensagem;
begin
  lblMensagem.Caption := EmptyStr;
end;

end.
