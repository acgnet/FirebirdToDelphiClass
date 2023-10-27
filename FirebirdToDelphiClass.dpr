program FirebirdToDelphiClass;

uses
  Vcl.Forms,
  uMain in 'view\uMain.pas' {frmMain},
  Controller.Base in 'controller\Controller.Base.pas' {ControllerBase: TDataModule},
  ConfiguracaoSistema in 'model\ConfiguracaoSistema.pas',
  uConfiguracao in 'view\uConfiguracao.pas' {frmConfiguracao},
  Controller.Tabela in 'controller\Controller.Tabela.pas' {ControllerTabela: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TControllerBase, ControllerBase);
  Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
  Application.CreateForm(TControllerTabela, ControllerTabela);
  Application.Run;
end.
