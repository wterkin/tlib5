unit tsqlite;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, sqlite3conn, sqldb, db
      , tstr;

type

{ TEasySQLite }
 TEasySQLite = class(TObject)

       private

         moQuery : TSQLQuery;
         msIDFieldName : String;
         miCurrentRowID : Integer;
       public

         constructor Create();
         procedure   setup(poDataBase: TSQLite3Connection; poDataSource: TDataSource = Nil);
         procedure   initialize(psSQL, psIDFieldName : String);
         function    open(pblReload : Boolean = False) : Boolean;
         procedure   store();
         procedure   reStore();
         function    eof() : Boolean;
         procedure   next();
         procedure   close();
         function    isClosed() : Boolean;
         procedure   parameter(psParamName : String; psParameter : String); overload;
         procedure   parameter(psParamName : String; piParameter : Integer); overload;
         function    stringField(psName : String) : String; overload;
         function    integerField(psName : String) : Integer; overload;
         procedure   setAfterScrollHandler(poProc : TDataSetNotifyEvent);
         destructor  Destroy(); override;
 end;

implementation

{ TEasySQLite }

constructor TEasySQLite.Create();
begin

  inherited;
  moQuery := TSQLQuery.Create(Nil);
end;


procedure TEasySQLite.setup(poDataBase : TSQLite3Connection; poDataSource : TDataSource);
begin

  moQuery.DataBase := poDataBase;
  if poDataSource <> Nil then
  begin

  	moQuery.DataSource := poDataSource;
	end;
end;


procedure TEasySQLite.initialize(psSQL, psIDFieldName : String);
begin

  msIDFieldName := psIDFieldName;
  if moQuery.State <> dsInactive then
  begin

    moQuery.Close;
  end;
  moQuery.SQL.Clear;
  moQuery.Params.Clear;
  moQuery.SQL.Delimiter:=LF;
  moQuery.SQL.AddDelimitedText(psSQL);
end;


function TEasySQLite.open(pblReload: Boolean): Boolean;
begin

  Result := False;
  try

    moQuery.Open();
    if pblReload then
    begin

      moQuery.Last;
		end;
		moQuery.First;
    Result := True;
	except
    // пока тут ничего не будет =)
	end;
end;


procedure TEasySQLite.store();
begin

  miCurrentRowID := moQuery.FieldByName(msIDFieldName).AsInteger;
end;


procedure TEasySQLite.reStore();
begin

  moQuery.Locate(msIDFieldName, miCurrentRowID{%H-}, []);
end;


function TEasySQLite.eof(): Boolean;
begin

  Result := moQuery.EOF;
end;


procedure TEasySQLite.next;
begin

  moQuery.Next;
end;


procedure TEasySQLite.close;
begin

  moQuery.Close();
end;


function TEasySQLite.isClosed: Boolean;
begin

  Result := moQuery.State <> dsInactive;
end;


procedure TEasySQLite.parameter(psParamName: String; psParameter: String);
begin

  moQuery.ParamByName(psParamName).AsString:=psParameter;
end;


procedure TEasySQLite.parameter(psParamName: String; piParameter: Integer);
begin

  moQuery.ParamByName(psParamName).AsInteger:=piParameter;
end;


function TEasySQLite.stringField(psName: String): String;
begin

  Result:=moQuery.FieldByName(psName).AsString;
end;


function TEasySQLite.integerField(psName: String): Integer;
begin

  Result:=moQuery.FieldByName(psName).AsInteger;
end;

procedure TEasySQLite.setAfterScrollHandler(poProc: TDataSetNotifyEvent);
begin

  moQuery.AfterScroll := poProc; //!!!

end;


destructor TEasySQLite.Destroy;
begin

  FreeAndNil(moQuery);
  inherited;
end;


end.

