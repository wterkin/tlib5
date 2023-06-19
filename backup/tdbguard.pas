unit tdbguard;

{$mode ObjFPC}{$H+}

interface

uses
      classes, SysUtils, SQLDB, DB, StdCtrls
      , tstr, thash, tdb
      ;

const ciEnteredStringIsCorrect =  0;
      ciEnteredStringIsEmpty   = -1;
      ciEnteredStringIsTooLong =  1;
      ciFBStringType           = 37;


type
      TDBFieldAttr = record

        msName   : String;
        mdwHash  : DWord;
        miLength : Integer;
        moType   : Integer;
      end;


      TTableGuard = class(TObject)
		    private

		      miFieldsCount : Integer;
		      maoFields     : array of TDBFieldAttr;
		      moQuery       : TSQLQuery;
		      moSourceQuery : TSQLQuery;
		      msTableName   : String;

		      function    openQuery() : Boolean;
		      procedure   closeQuery();
		      procedure   allocateMemory();
		      procedure   freeMemory();
		      procedure   loadFields();
		      function    findField(psFieldName : String) : Integer;
		    public

		      constructor create(poQuery : TSQLQuery; psTableName : String);
		      destructor  destroy(); override;
		      function    isStringValueFit(psFieldName : String; psValue : String) : Boolean;
		      function    isStringValueCorrect(psFieldName,psValue : String) : Integer;
		      function    getFieldLength(psFieldName : String) : Integer;
		      procedure   setSourceQuery(poQuery : TSQLQuery);
		      function    theProcrusteanBed(psSourceFieldName, psTargetFieldName : String) : String;
		      procedure   loadStringField(poEdit : TEdit; psFieldName : String);
		      procedure   initStringField(poEdit : TEdit; psFieldName : String);
		      procedure   initMemoField(poMemo : TMemo; psFieldName : String);
		      procedure   loadMemoField(poMemo : TMemo; psFieldName : String);
		  end;

implementation
{ TTableGuard }

constructor TTableGuard.create(poQuery : TSQLQuery; psTableName : String);
begin

  moQuery:=poQuery;
  msTableName:=UpperCase(psTableName);
  if openQuery() then begin

    allocateMemory();
    loadFields();
  end else begin

    raise EDatabaseError.Create('Таблица '+msTableName+' не может быть открыта.');
  end;
end;


destructor TTableGuard.destroy;
begin

  closeQuery();
  freeMemory();
  inherited;
end;


function TTableGuard.openQuery: Boolean;
const csSQLTableInfo =
        'select R.RDB$FIELD_NAME as afieldname,'+
        '       F.RDB$CHARACTER_LENGTH as afieldlength, '+
        '       F.RDB$FIELD_TYPE as afieldtype '+
        '  from RDB$FIELDS F, RDB$RELATION_FIELDS R'+
        '  where (F.RDB$FIELD_NAME = R.RDB$FIELD_SOURCE) and '+
        '        (R.RDB$SYSTEM_FLAG = 0) and'+
        '        (R.RDB$RELATION_NAME=:ptablename) '+
        '  order by R.RDB$FIELD_POSITION';
begin

  Result:=True;
  try

    initializeQuery(moQuery, csSQLTableInfo);
    moQuery.ParamByName('ptablename').AsString:=msTableName;
    moQuery.Open;
  except

    Result:=False;
  end;
end;


procedure TTableGuard.closeQuery;
begin

  moQuery.Close;
  TSQLTransaction(moQuery.Transaction).EndTransaction;
end;


procedure TTableGuard.allocateMemory;
begin

  moQuery.Last;
  miFieldsCount:=moQuery.RecordCount; // тут
  SetLength(maoFields,miFieldsCount);
end;


procedure TTableGuard.freeMemory;
begin

  SetLength(maoFields,0);
end;


procedure TTableGuard.loadFields;
var liFieldIdx : Integer;
begin

  liFieldIdx:=0;
  moQuery.First;
  while not moQuery.EOF do
  begin

    maoFields[liFieldIdx].msName:=upperTrimLine(moQuery.FieldByName('afieldname').AsString);
    maoFields[liFieldIdx].mdwHash:=calcStringHash(maoFields[liFieldIdx].msName);
    maoFields[liFieldIdx].moType:=moQuery.FieldByName('afieldtype').AsInteger;
    maoFields[liFieldIdx].miLength:=moQuery.FieldByName('afieldlength').AsInteger;
    moQuery.Next;
    inc(liFieldIdx);
  end;
  if liFieldIdx=0 then
  begin

    raise EDatabaseError.Create('No fields was found in table '+msTableName+
      '. Possibly this table is not exist or typed incorrectly ');
	end;
end;


function TTableGuard.findField(psFieldName : String): Integer;
var ldwHash    : DWord;
    liFieldIdx : Integer;
    lsFieldName : String;
begin

  Result:=-1;
  lsFieldName:=upperTrimLine(psFieldName);
  ldwHash:=CalcStringHash(lsFieldName);
  for liFieldIdx:=0 to miFieldsCount-1 do
  begin

    if maoFields[liFieldIdx].mdwHash=ldwHash then
    begin

      if maoFields[liFieldIdx].msName=lsFieldName then
      begin

        Result:=liFieldIdx;
        break;
      end;
    end;
  end;
  if Result<0 then
  begin

    raise EDatabaseError.Create('Target field '+psFieldName+' is not exist or typed incorrectly ');
  end;
end;


function TTableGuard.isStringValueFit(psFieldName: String; psValue: String): Boolean;
var liFieldIdx : Integer;
begin

  Result:=False;
  liFieldIdx:=findField(psFieldName);
  if maoFields[liFieldIdx].moType<>ciFBStringType then
  begin

    raise EDatabaseError.Create('Поле '+psFieldName+' не является строковым. '+#13+'Проверка не удалась.');
	end;
	Result:=Length(psValue)<=(maoFields[liFieldIdx].miLength div 2); // UTF8 же!
end;


function TTableGuard.isStringValueCorrect(psFieldName,psValue : String): Integer;
begin

  Result:=ciEnteredStringIsCorrect;
  //***** Проверим, содержит ли что-то это значение
  if isEmpty(psValue) then
  begin

    Result:=ciEnteredStringIsEmpty;
  end
  else
  begin

    if not isStringValueFit(psFieldName,psValue) then
    begin

      Result:=ciEnteredStringIsTooLong;
    end;
  end;
end;


function TTableGuard.getFieldLength(psFieldName: String): Integer;
begin

  Result:=maoFields[findField(psFieldName)].miLength div 2; // UTF8!
end;


procedure TTableGuard.setSourceQuery(poQuery: TSQLQuery);
begin

  moSourceQuery:=poQuery;
end;


function TTableGuard.theProcrusteanBed(psSourceFieldName,
  psTargetFieldName: String): String;
var lsValue : String;
begin

  Result:='';
  if moSourceQuery<>Nil then
  begin

    lsValue:=moSourceQuery.FieldByName(psSourceFieldName).AsString;
    if Length(lsValue)>getFieldLength(psTargetFieldName) then
    begin

      Raise EDatabaseError.Create('TDBGuard: Data in source field '+psSourceFieldName+#13+
        ' does not fit in the target field '+msTableName+':'+psTargetFieldName+' !'#13+lsValue);
    end else
    begin

      Result:=lsValue;
    end;
  end
  else
  begin

    Raise EDatabaseError.Create('TDBGuard: sourceQuery not assigned!');
  end;
end;


procedure TTableGuard.loadStringField(poEdit: TEdit; psFieldName: String);
begin

  if moSourceQuery<>Nil then
  begin

    poEdit.Text:=moSourceQuery.FieldByName(psFieldName).AsString;
    poEdit.MaxLength:=getFieldLength(psFieldName);
  end
  else
  begin

    Raise EDatabaseError.Create('TDBGuard: sourceQuery not assigned!');
  end;
end;


procedure TTableGuard.initStringField(poEdit: TEdit; psFieldName: String);
begin

  poEdit.Text:='';
  poEdit.MaxLength:=getFieldLength(psFieldName) div 2;
end;


procedure TTableGuard.initMemoField(poMemo: TMemo; psFieldName: String);
begin

  poMemo.Text:='';
  poMemo.MaxLength:=getFieldLength(psFieldName) div 2;
end;


procedure TTableGuard.loadMemoField(poMemo: TMemo; psFieldName: String);
begin

  if moSourceQuery<>Nil then
  begin

    poMemo.Text:=moSourceQuery.FieldByName(psFieldName).AsString;
    poMemo.MaxLength:=getFieldLength(psFieldName);
  end
  else
  begin

    Raise EDatabaseError.Create('TDBGuard: sourceQuery not assigned!');
  end;
end;

end.

