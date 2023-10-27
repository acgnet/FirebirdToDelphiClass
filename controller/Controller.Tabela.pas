unit Controller.Tabela;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.StdCtrls;

type
  TControllerTabela = class(TDataModule)
    fdqTabela: TFDQuery;
    fdqTabelaTABELA: TStringField;
  private
    function PegaCampoChave(ATabela: string): string;
    procedure PreencheCabecalho(var AMemo: TMemo; ATabela: string);
    procedure AddLinha(var AMemo: TMemo);
    procedure PreencheRodape(var AMemo: TMemo);
    procedure PreencheAreaPublica(var AMemo: TMemo);
    function GetTipo(AType: TFieldType): string;
    { Private declarations }
  public
    { Public declarations }
    procedure GeraClasse(var AMemo: TMemo; ATabela: string);
  end;

var
  ControllerTabela: TControllerTabela;

implementation

uses
  Controller.Base;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TControllerTabela }

procedure TControllerTabela.GeraClasse(Var AMemo: TMemo; ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
begin
  AMemo.Lines.Clear;
  PreencheCabecalho(AMemo, ATabela);

  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Tipo := GetTipo(Field.DataType);

      AMemo.Lines.Add(Format('  %s : %s;',['F'+FieldName, Tipo]));
    end;

    PreencheAreaPublica(AMemo);

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Tipo := GetTipo(Field.DataType);
      AMemo.Lines.Add(
       '  property '+ Fieldname + ' : '+ Tipo +' read F'+FieldName + ' write F'+FieldName + ';');
    end;

  finally
    PreencheRodape(AMemo);
    qry.Close;
    FreeAndNil(qry);
  end;
end;


function TControllerTabela.PegaCampoChave(ATabela: string): string;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('select i.rdb$field_name from rdb$index_segments i');
    qry.SQL.Add('join rdb$relation_constraints c on (i.rdb$index_name=c.rdb$index_name)');
    qry.SQL.Add('where c.rdb$constraint_type=' + QuotedStr('PRIMARY KEY'));
    qry.SQL.Add('and c.rdb$relation_name='+ QuotedStr(ATabela));
    qry.Open;

    result := qry.Fields[0].AsString;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.PreencheCabecalho(Var AMemo: TMemo; ATabela: String);
begin
  AMemo.Lines.Add(Format('unit %s;', ['u'+ATabela]));
  AddLinha(AMemo);
  AMemo.Lines.Add('interface');
  AddLinha(AMemo);
  AMemo.Lines.Add(Format('type %s = class',['T'+ATabela]));
  AddLinha(AMemo);
  AMemo.Lines.Add('private');
end;

procedure TControllerTabela.PreencheAreaPublica(Var AMemo: TMemo);
begin
  AddLinha(AMemo);
  AMemo.Lines.Add('public');
end;


procedure TControllerTabela.PreencheRodape(Var AMemo: TMemo);
begin
  AMemo.Lines.Add('end;');
  AddLinha(AMemo);
  AMemo.Lines.Add('implementation');
  AddLinha(AMemo);
  AMemo.Lines.Add('end.');
end;


procedure TControllerTabela.AddLinha(var AMemo: TMemo);
begin
  AMemo.Lines.Add('');
end;


function TControllerTabela.GetTipo(AType: TFieldType): string;
begin
  case AType of
    ftSmallint,
    ftInteger,
    ftWord: Result := 'Integer';

    ftBoolean: Result := 'Boolean';

    ftFloat, ftCurrency, ftBCD: Result := 'Real';

    ftDate: Result := 'TDate';

    ftDateTime, ftTimeStamp: Result := 'TDateTime';

    else
      Result := 'string';
  end;
end;

end.
