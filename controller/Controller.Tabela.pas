unit Controller.Tabela;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.StdCtrls, System.StrUtils;

type
  TControllerTabela = class(TDataModule)
    fdqTabela: TFDQuery;
    fdqTabelaTABELA: TStringField;
  private
    function PegaCampoChave(ATabela: string): string;
    procedure PreencheCabecalhoClasse(var AMemo: TMemo; ATabela: string);
    procedure AddLinha(var AMemo: TMemo);
    procedure PreencheRodapeClasse(var AMemo: TMemo);
    procedure PreencheAreaPublica(var AMemo: TMemo);
    function GetTipo(AType: TFieldType): string;
    function FormatCamelCase(input: string): string;

    procedure PreencheCabecalhoController(var AMemo: TMemo; ATabela: String);
    procedure PreencheRodapeController(var AMemo: TMemo);
    function GetTipoBd(AType: TFieldType): string;
    { Private declarations }
  public
    { Public declarations }
    procedure GeraClasse(var AMemo: TMemo; ATabela: string);
    procedure GeraController(var AMemo: TMemo; ATabela: string);
  end;

var
  ControllerTabela: TControllerTabela;

implementation

uses
  Controller.Base, System.Types;

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
  PreencheCabecalhoClasse(AMemo, ATabela);

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
    PreencheRodapeClasse(AMemo);
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

    if qry.IsEmpty then
      result := 'Id'+ATabela
    else
      result := qry.Fields[0].AsString;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.PreencheCabecalhoClasse(Var AMemo: TMemo; ATabela: String);
var
  ATabelaCamelCase: string;
begin
  ATabelaCamelCase := FormatCamelCase(ATabela);
  AMemo.Lines.Add(Format('unit %s;', ['Model.'+ ATabelaCamelCase]));
  AddLinha(AMemo);
  AMemo.Lines.Add('interface');
  AddLinha(AMemo);
  AMemo.Lines.Add(Format('type %s = class',['T'+ATabelaCamelCase]));
  AddLinha(AMemo);
  AMemo.Lines.Add('private');
end;

procedure TControllerTabela.PreencheAreaPublica(Var AMemo: TMemo);
begin
  AddLinha(AMemo);
  AMemo.Lines.Add('public');
end;


procedure TControllerTabela.PreencheRodapeClasse(Var AMemo: TMemo);
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

function TControllerTabela.GetTipoBd(AType: TFieldType): string;
begin
  case AType of
    ftSmallint,
    ftInteger,
    ftWord: Result := 'AsInteger';

    ftBoolean: Result := 'AsBoolean';

    ftFloat, ftCurrency, ftBCD: Result := 'AsFloat';

    ftDate: Result := 'AsDate';

    ftDateTime, ftTimeStamp: Result := 'AsDateTime';

    else
      Result := 'AsString';
  end;
end;



function TControllerTabela.FormatCamelCase(input: string): string;
var
  words: TStringDynArray;
  word: string;
  i: Integer;
begin
  words := SplitString(input, ' ');

  Result := '';

  for i := 0 to High(words) do
  begin
    word := words[i];

    if word <> '' then
    begin
      // Converta a primeira letra em maiúscula e o restante em minúsculas
      word := UpperCase(word[1]) + LowerCase(Copy(word, 2, Length(word) - 1));
      // Adicione a palavra formatada à string de saída
      Result := Result + word;
    end;
  end;
end;

procedure TControllerTabela.PreencheCabecalhoController(Var AMemo: TMemo; ATabela: String);
var
  Chave: string;
begin
  Chave := PegaCampoChave(ATabela);

  AMemo.Lines.Add(Format('unit %s;', ['Controller.'+ ATabela]));
  AddLinha(AMemo);
  AMemo.Lines.Add('interface');
  AddLinha(AMemo);
  AMemo.Lines.Add('uses');
  AMemo.Lines.Add('System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,');
  AMemo.Lines.Add('FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,');
  AMemo.Lines.Add('FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,           ');
  AMemo.Lines.Add('FireDAC.Comp.DataSet, FireDAC.Comp.Client, '+ 'Model.'+ ATabela +';');
  AddLinha(AMemo);
  AMemo.Lines.Add('type TController'+ATabela + ' = class(TDataModule)');
  AddLinha(AMemo);
  AMemo.Lines.Add('private');
  AddLinha(AMemo);
  AMemo.Lines.Add('public');
  AMemo.Lines.Add(Format('  function Get%s(var A'+ATabela+': T%s; Id: String): Boolean;',[ATabela, ATabela]));
  AMemo.Lines.Add('end;');
  AddLinha(AMemo);
  AMemo.Lines.Add('Var');
  AMemo.Lines.Add('  Controller'+ATabela+':' + 'TController'+ATabela+';');
  AddLinha(AMemo);
  AMemo.Lines.Add('implementation');
  AddLinha(AMemo);
  AMemo.Lines.Add('{%CLASSGROUP ''Vcl.Controls.TControl''}');
  AddLinha(AMemo);
  AMemo.Lines.Add('{$R *.dfm}');
  AddLinha(AMemo);
  AMemo.Lines.Add('uses');
  AMemo.Lines.Add(' Controller.Base;');
  AddLinha(AMemo);
  AMemo.Lines.Add(Format('function TController'+ATabela+'.Get%s(var A'+ ATabela +': T%s; Id: String): Boolean;',[ATabela, ATabela]));
  AMemo.Lines.Add('var');
  AMemo.Lines.Add('qry: TFDQuery;');
  AMemo.Lines.Add('begin');
  AMemo.Lines.Add('  qry := TFDQuery.Create(nil);');
  AMemo.Lines.Add('  try');
  AMemo.Lines.Add('    qry.Connection := ControllerBase.con;');
  AMemo.Lines.Add('    qry.SQL.Add(''select * from '+ATabela +''');');
  AMemo.Lines.Add('    qry.SQL.Add(''where '+ATabela +'.'+ Chave +' =:'+ Chave+''');');
  AMemo.Lines.Add('    qry.ParamByName('''+ Chave +''').AsString := id;');
  AMemo.Lines.Add('    qry.Open;');
  AddLinha(AMemo);
  AMemo.Lines.Add('    if qry.IsEmpty then');
  AMemo.Lines.Add('      Result := False');
  AMemo.Lines.Add('    else');
  AMemo.Lines.Add('    begin');
end;

procedure TControllerTabela.PreencheRodapeController(Var AMemo: TMemo);
begin
  AMemo.Lines.Add('      result := True;');
  AMemo.Lines.Add('    end;');
  AddLinha(AMemo);
  AMemo.Lines.Add('  finally');
  AMemo.Lines.Add('    qry.close;');
  AMemo.Lines.Add('    FreeAndNil(qry);');
  AMemo.Lines.Add('  end;');
  AMemo.Lines.Add('end;');
  AMemo.Lines.Add('end.');
end;



procedure TControllerTabela.GeraController(Var AMemo: TMemo; ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
  ATabelaCamelCase: string;
begin
  AMemo.Lines.Clear;
  ATabelaCamelCase := FormatCamelCase(ATabela);
  PreencheCabecalhoController(AMemo, ATabelaCamelCase);
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Tipo := GetTipoBd(Field.DataType);

      AMemo.Lines.Add(Format('      A%s.%s := Qry.FieldByName(''%s'').%s;',[ATabelaCamelCase, FieldName, FieldName, Tipo]));
    end;

  finally
    PreencheRodapeController(AMemo);
    qry.Close;
    FreeAndNil(qry);
  end;
end;


end.
