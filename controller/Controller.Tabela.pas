unit Controller.Tabela;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.StdCtrls, System.StrUtils;

type TChave = record
  Nome,
  Tipo,
  TipoBd,
  Valor: string;
end;

type TChaves = array of TChave;

type
  TControllerTabela = class(TDataModule)
    fdqTabela: TFDQuery;
    fdqTabelaTABELA: TStringField;
  private
    function PegaCampoChave(ATabela: string): TChaves;
    procedure PreencheCabecalhoClasse(var AMemo: TMemo; ATabela: string);
    procedure AddLinha(var AMemo: TMemo);
    procedure PreencheRodapeClasse(var AMemo: TMemo);
    procedure PreencheAreaPublica(Var AMemo: TMemo; ATabela: string);
    function GetTipo(AType: TFieldType): string;
    function FormatCamelCase(input: string): string;

    procedure PreencheCabecalhoController(var AMemo: TMemo; ATabela: String);
    procedure PreencheRodapeController(var AMemo: TMemo);
    function GetTipoBd(AType: TFieldType): string;
    procedure GeraInsertCrud(var AMemo: TMemo; ATabela: string);
    function GetFieldsFromTable(ATabela: string; AParametro: string = ''): string;
    procedure PreencheParametrosInsert(var AMemo: TMemo; Prefixo, ATabela: string);
    procedure GeraUpdateCrud(var AMemo: TMemo; ATabela: string);
    procedure PrencheFieldsParaUpdate(var AMemo: TMemo; Texto, Prefixo, Separador,
      ATabela: string);
    procedure PrencheParametrosParaUpdate(var AMemo: TMemo; Prefixo,
      ATabela: string);
    procedure GeraDeleteCrud(var AMemo: TMemo; ATabela: string; Chaves: TChaves);
    function GetTipoField(ATabela, AField: string): TChave;
    procedure GeraReadCrud(var AMemo: TMemo; ATabela: string; Chaves: TChaves);
    function ChavesParaString(Chaves: TChaves): string;
    procedure ReadBancoPreencheObjeto(var AMemo: TMemo; Prefixo,
      ATabela: string);
    procedure PrencheFieldsParaInsert(var AMemo: TMemo; AScript, IndicadorParametro, ATabela: string);
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

function RemoverEspacos(const AString: string): string;
begin
  Result := StringReplace(AString, ' ', '', [rfReplaceAll]);
end;

function TControllerTabela.ChavesParaString(Chaves: TChaves): string;
var
  AChave: TChave;
  ChaveTemp: String;
begin
  ChaveTemp := EmptyStr;

  for AChave in Chaves do
    ChaveTemp := Chavetemp + Format(' %s: %s;',[AChave.Nome, AChave.Tipo]);

  Result := Copy(ChaveTemp, 1, Length(ChaveTemp)-1);
end;

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

    PreencheAreaPublica(AMemo, ATabela);

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


function TControllerTabela.PegaCampoChave(ATabela: string): TChaves;
var
  qry: TFDQuery;
  ATamanho: Integer;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('select i.rdb$field_name from rdb$index_segments i');
    qry.SQL.Add('join rdb$relation_constraints c on (i.rdb$index_name=c.rdb$index_name)');
    qry.SQL.Add('where c.rdb$constraint_type=' + QuotedStr('PRIMARY KEY'));
    qry.SQL.Add('and c.rdb$relation_name='+ QuotedStr(UpperCase(ATabela)));
    qry.Open;

    ATamanho := 0;
    qry.First;
    while not qry.eof do
    begin
      Inc(ATamanho);
      SetLength(Result, ATamanho);
      Result[ATamanho-1] := GetTipoField(ATabela, qry.Fields[0].AsString);
      qry.Next;
    end;
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

procedure TControllerTabela.PreencheAreaPublica(Var AMemo: TMemo; ATabela: string);
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
  ATabelaCamelCase: string;
  Chave: TChaves;
  AChaveString: string;
begin
  Chave := PegaCampoChave(ATabela);
  AChaveString := ChavesParaString(Chave);
  ATabelaCamelCase := FormatCamelCase(ATabela);

  AMemo.Lines.Add(Format('unit %s;', ['Controller.'+ ATabela]));
  AddLinha(AMemo);
  AMemo.Lines.Add('interface');
  AddLinha(AMemo);
  AMemo.Lines.Add('uses');
  AMemo.Lines.Add('  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,');
  AMemo.Lines.Add('  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,');
  AMemo.Lines.Add('  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,           ');
  AMemo.Lines.Add('  FireDAC.Comp.DataSet, FireDAC.Comp.Client, '+ 'Model.'+ ATabela +';');
  AddLinha(AMemo);
  AMemo.Lines.Add('type TController'+ATabela + ' = class(TDataModule)');
  AddLinha(AMemo);
  AMemo.Lines.Add('private');
  AddLinha(AMemo);
  AMemo.Lines.Add('public');
  AMemo.Lines.Add(Format('  function Create%s(var A%s: T%s): Boolean;',[ATabelaCamelCase, ATabelaCamelCase, ATabelaCamelCase]));
  AMemo.Lines.Add(Format('  function Read%s(var A%s: T%s; %s): Boolean;',[ATabela, ATabela, ATabela, AChaveString]));
  AMemo.Lines.Add(Format('  function Update%s(var A%s: T%s): Boolean;',[ATabelaCamelCase, ATabelaCamelCase, ATabelaCamelCase]));
  AMemo.Lines.Add(Format('  function Delete%s(%s):Boolean;',[ATabelaCamelCase, AChaveString]));

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
  GeraInsertCrud(AMemo, ATabelaCamelCase);
  AddLinha(AMemo);
  GeraReadCrud(AMemo, ATabelaCamelCase,  Chave);
  GeraUpdateCrud(AMemo, ATabelaCamelCase);
  AddLinha(AMemo);
  GeraDeleteCrud(AMemo, ATabelaCamelCase, Chave);
  AddLinha(AMemo);
end;

procedure TControllerTabela.PreencheRodapeController(Var AMemo: TMemo);
begin
  AMemo.Lines.Add('end.');
end;

procedure TControllerTabela.GeraController(Var AMemo: TMemo; ATabela: string);
var
  ATabelaCamelCase: string;
begin
  AMemo.Lines.Clear;
  ATabelaCamelCase := FormatCamelCase(ATabela);
  PreencheCabecalhoController(AMemo, ATabelaCamelCase);
  PreencheRodapeController(AMemo);
end;

function TControllerTabela.GetFieldsFromTable(ATabela: string; AParametro: String = ''): string;
var
  qry: TFDQuery;
  ATabelaCamelCase: string;
  ACampos: string;

begin
  ATabelaCamelCase := FormatCamelCase(ATabela);


  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;

    qry.sql.Text :=
    'SELECT LIST(RDB$FIELD_NAME) CAMPOS FROM RDB$RELATION_FIELDS '+
    'WHERE RDB$RELATION_NAME = '+ UpperCase(QuotedStr(ATabela));
    qry.open;

    ACampos := RemoverEspacos(qry.FieldByName('CAMPOS').AsString);

    if AParametro <> EmptyStr then
      ACampos := ':'+StringReplace(ACampos, ',', ',:', [rfReplaceAll]);

    Result := ACampos;
  finally

    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.PrencheFieldsParaUpdate(Var AMemo: TMemo; Texto, Prefixo, Separador, ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
  ATabelaCamelCase: string;
  TotFields, IdxField: Integer;
begin
  ATabelaCamelCase := FormatCamelCase(ATabela);
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;


    TotFields := qry.Fields.Count;
    IdxField := 0;
    for Field in qry.Fields do
    begin
      Inc(IdxField);
      FieldName := Field.FieldName;
      Tipo := GetTipoBd(Field.DataType);

      if IdxField = TotFields then
        AMemo.Lines.Add(Format(' %s(''%s%s = :%s%s'');', [Texto, Prefixo, FieldName,FieldName, '']))
      else
        AMemo.Lines.Add(Format(' %s(''%s%s = :%s%s'');', [Texto, Prefixo, FieldName,FieldName, Separador]));

    end;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.PrencheFieldsParaInsert(Var AMemo: TMemo; AScript, IndicadorParametro, ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
  ATabelaCamelCase: string;
  TotFields, IdxField: Integer;
begin
  ATabelaCamelCase := FormatCamelCase(ATabela);
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;


    TotFields := qry.Fields.Count;
    IdxField := 0;
    for Field in qry.Fields do
    begin
      Inc(IdxField);
      FieldName := Field.FieldName;
      Tipo := GetTipoBd(Field.DataType);

      if IdxField = TotFields then
        AMemo.Lines.Add(Format('    %s ''%s%s)'');', [AScript, IndicadorParametro, FieldName]))
      else
        AMemo.Lines.Add(Format('    %s ''%s%s,'');', [AScript, indicadorParametro,FieldName]));

    end;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.PrencheParametrosParaUpdate(Var AMemo: TMemo; Prefixo, ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
  ATabelaCamelCase: string;
begin
  ATabelaCamelCase := FormatCamelCase(ATabela);
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Tipo := GetTipoBd(Field.DataType);

      AMemo.Lines.Add(Format('    %s(''%s'').%s := A%s.%s;',
        [Prefixo, FieldName, Tipo, ATabelaCamelCase, FieldName]));
    end;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;


procedure TControllerTabela.PreencheParametrosInsert(Var AMemo: TMemo; Prefixo, ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
  ATabelaCamelCase: string;
begin
  ATabelaCamelCase := FormatCamelCase(ATabela);
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Tipo := GetTipoBd(Field.DataType);

      AMemo.Lines.Add(Format('    %s(''%s'').%s := A%s.%s;',
        [Prefixo, FieldName, Tipo, ATabelaCamelCase, FieldName]));
    end;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.GeraInsertCrud(var AMemo: TMemo; ATabela: string);
begin
  AMemo.Lines.Add(Format('function TController%s.Create%s(var A%s: T%s): Boolean;',[ATabela, ATabela, ATabela, ATabela]));
  AMemo.Lines.Add('var');
  AMemo.Lines.Add('  qry: TFDQuery;');
  AMemo.Lines.Add('begin');
  AMemo.Lines.Add('  qry := TFDQuery.Create(nil);');
  AMemo.Lines.Add('  try');
  AMemo.Lines.Add('    qry.Connection := ControllerBase.con;');
  AMemo.Lines.Add('    Result := False;');
  AMemo.Lines.Add('    qry.SQL.Add('+Format('''INSERT INTO %s('');',[ATabela]));

  PrencheFieldsParaInsert(AMemo,'qry.SQL.Add(','', ATabela);

  AMemo.Lines.Add('    qry.SQL.Add(''VALUES('');');

  PrencheFieldsParaInsert(AMemo, 'qry.SQL.Add(', ':', ATabela);
  AMemo.Lines.Add('    try');

  PreencheParametrosInsert(AMemo,'  qry.ParamByName', ATabela);

  AMemo.Lines.Add('');
  AMemo.Lines.Add('    qry.ExecSQL;');
  AMemo.Lines.Add('    Result := qry.RowsAffected > 0;');
  AMemo.Lines.Add('    except');
  AMemo.Lines.Add('      on E: Exception do');
  AMemo.Lines.Add('      begin');
  AMemo.Lines.Add('        // Aqui você pode adicionar o tratamento de exceção que achar necessário');
  AMemo.Lines.Add('        raise;');
  AMemo.Lines.Add('      end;');
  AMemo.Lines.Add('    end;');
  AMemo.Lines.Add('  finally');
  AMemo.Lines.Add('    qry.close;');
  AMemo.Lines.Add('    freeandnil(qry);');
  AMemo.Lines.Add('  end;');

  AMemo.Lines.Add('end;');
  AMemo.Lines.Add(EmptyStr);
end;

procedure TControllerTabela.GeraReadCrud(var AMemo: TMemo; ATabela: string; Chaves: TChaves);
var
  Chave: TChave;
  ChaveString: string;
begin
  ChaveString := ChavesParaString(Chaves);

  AMemo.Lines.Add(Format('function TController'+ATabela+'.Read%s(var A'+ ATabela +': T%s; %s): Boolean;',[ATabela, ATabela, ChaveString]));
  AMemo.Lines.Add('var');
  AMemo.Lines.Add('  qry: TFDQuery;');
  AMemo.Lines.Add('begin');
  AMemo.Lines.Add('  qry := TFDQuery.Create(nil);');
  AMemo.Lines.Add('  try');
  AMemo.Lines.Add('    try');
  AMemo.Lines.Add('      qry.Connection := ControllerBase.con;');
  AMemo.Lines.Add('      qry.SQL.Add(''select * from '+ATabela +''');');
  AMemo.Lines.Add('      qry.SQL.Add(''where 1=1'');');

  for Chave in Chaves do
  begin
    AMemo.Lines.Add(Format('      qry.SQL.Add(''and %s.%s =:%s'');',[ATabela, Chave.Nome, Chave.Nome]));
  end;

  for Chave in Chaves do
  begin
    AMemo.Lines.Add(Format('      qry.ParamByName('''+ Chave.Nome +''').%s := %s;',[Chave.TipoBd, Chave.Nome]));
  end;

  AMemo.Lines.Add('      qry.Open;');
  AddLinha(AMemo);
  AMemo.Lines.Add('      if qry.IsEmpty then');
  AMemo.Lines.Add('        Result := False');
  AMemo.Lines.Add('      else');
  AMemo.Lines.Add('      begin');
  ReadBancoPreencheObjeto(AMemo,'  qry.FieldByName', ATabela);
  AMemo.Lines.Add('        result := True;');
  AMemo.Lines.Add('      end;');
  AMemo.Lines.Add('    Except');
  AMemo.Lines.Add('      Result := False;');
  AMemo.Lines.Add('    End;');
  AddLinha(AMemo);
  AMemo.Lines.Add('  finally');
  AMemo.Lines.Add('    qry.close;');
  AMemo.Lines.Add('    FreeAndNil(qry);');
  AMemo.Lines.Add('  end;');
  AMemo.Lines.Add('end;');
  AMemo.Lines.Add('');
end;

procedure TControllerTabela.GeraUpdateCrud(var AMemo: TMemo; ATabela: string);
begin
  AMemo.Lines.Add(Format('function TController%s.Update%s(var A%s: T%s): Boolean;',[ATabela, ATabela, ATabela, ATabela]));
  AMemo.Lines.Add('var');
  AMemo.Lines.Add('  qry: TFDQuery;');
  AMemo.Lines.Add('begin');
  AMemo.Lines.Add('  qry := TFDQuery.Create(nil);');
  AMemo.Lines.Add('  try');
  AMemo.Lines.Add('    qry.Connection := Controller.con;');
  AMemo.Lines.Add('    Result := False;');
  AMemo.Lines.Add('');
  AMemo.Lines.Add('    qry.SQL.Add('+Format('''UPDATE %s SET'');',[ATabela,GetFieldsFromTable(ATabela)]));

  PrencheFieldsParaUpdate(AMemo,'   qry.sql.add', '',',', ATabela);

  AMemo.Lines.Add('    qry.SQL.Add(''WHERE 1=1'');');

  PrencheFieldsParaUpdate(AMemo,'   qry.sql.add', 'AND ', '', ATabela);

  AMemo.Lines.Add('    try');
  PrencheParametrosParaUpdate(AMemo,'  qry.ParamByName', ATabela);
  AMemo.Lines.Add('');
  AMemo.Lines.Add('      qry.ExecSQL;');
  AMemo.Lines.Add('      Result := qry.RowsAffected > 0;');
  AMemo.Lines.Add('    except');
  AMemo.Lines.Add('      on E: Exception do');
  AMemo.Lines.Add('      begin');
  AMemo.Lines.Add('        // Aqui você pode adicionar o tratamento de exceção que achar necessário');
  AMemo.Lines.Add('        raise;');
  AMemo.Lines.Add('      end;');
  AMemo.Lines.Add('    end;');
  AMemo.Lines.Add('  finally');
  AMemo.Lines.Add('    qry.close;');
  AMemo.Lines.Add('    FreeAndNil(qry);');
  AMemo.Lines.Add('  end;');
  AMemo.Lines.Add('end;');
  AMemo.Lines.Add(EmptyStr);
end;

procedure TControllerTabela.GeraDeleteCrud(var AMemo: TMemo; ATabela: string; Chaves: TChaves);
var
  ChaveString: string;
  Chave: TChave;
begin
  ChaveString := ChavesParaString(Chaves);

  // Implementação do método para deletar um registro do banco
  AMemo.Lines.Add(Format('function TController%s.Delete%s(%s): Boolean;',[ATabela, ATabela, ChaveString]));
  AMemo.Lines.Add('var');
  AMemo.Lines.Add('  qry: TFDQuery;');
  AMemo.Lines.Add('begin');
  AMemo.Lines.Add('  qry := TFDQuery.Create(nil);');
  AMemo.Lines.Add('  try');
  AMemo.Lines.Add('    qry.Connection := Controller.con;');
  AMemo.Lines.Add('    Result := False;');

  AMemo.Lines.Add(Format('    qry.SQL.Add(''DELETE FROM %s WHERE 1=1'');',[ATabela]));

  for Chave in Chaves do
    AMemo.Lines.Add(Format('    qry.Sql.Add(''AND %s =:%s'');',[Chave.Nome, Chave.Nome]));

  AMemo.Lines.Add('    try');

  for Chave in Chaves do
    AMemo.Lines.Add(Format('      qry.ParamByName(''%s'').%s := %s;',[Chave.Nome, Chave.TipoBd, Chave.Nome]));

  AMemo.Lines.Add('      qry.ExecSQL;');
  AMemo.Lines.Add('      Result := qry.RowsAffected > 0;');
  AMemo.Lines.Add('    except');
  AMemo.Lines.Add('      on E: Exception do');
  AMemo.Lines.Add('      begin');
  AMemo.Lines.Add('        // Aqui você pode adicionar o tratamento de exceção que achar necessário');
  AMemo.Lines.Add('        raise;');
  AMemo.Lines.Add('      end;');
  AMemo.Lines.Add('    end;');
  AMemo.Lines.Add('  finally');
  AMemo.Lines.Add('    qry.close;');
  AMemo.Lines.Add('    freeandnil(qry);');
  AMemo.Lines.Add('  end;');
  AMemo.Lines.Add('end;');
end;

function TControllerTabela.GetTipoField(ATabela, AField: string): TChave;
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
begin
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 '+ AField +' FROM '+ ATabela);
    qry.Open;

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Result.Nome := FieldName;
      Result.TipoBd := GetTipoBd(Field.DataType);
      Result.Tipo := GetTipo(Field.DataType);
    end;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;

procedure TControllerTabela.ReadBancoPreencheObjeto(Var AMemo: TMemo; Prefixo, ATabela: string);
var
  qry: TFDQuery;
  FieldName: string;
  Field: TField;
  Tipo: string;
  ATabelaCamelCase: string;
begin
  ATabelaCamelCase := FormatCamelCase(ATabela);
  qry := TFDQuery.Create(nil);

  try
    qry.Connection := ControllerBase.conBase;
    qry.SQL.Add('SELECT FIRST 1 * FROM '+ ATabela);
    qry.Open;

    for Field in qry.Fields do
    begin
      FieldName := Field.FieldName;
      Tipo := GetTipoBd(Field.DataType);

      AMemo.Lines.Add(Format('        A%s.%s := %s(''%s'').%s;',
        [ATabelaCamelCase, FieldName, Prefixo, FieldName, Tipo]));
    end;

  finally
    qry.Close;
    FreeAndNil(qry);
  end;
end;



end.
