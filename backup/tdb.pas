unit tdb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db
  , tstr
  ;

procedure initializeQuery(poQuery : TSQLQuery; psSQL : String; pblRestartTransaction : Boolean = True);

procedure parseSQLToQuery(poQuery: TSQLQuery; psSQL : String);

implementation

procedure initializeQuery(poQuery : TSQLQuery; psSQL : String; pblRestartTransaction : Boolean);
begin

  if poQuery.State<>dsInactive then
  begin

    poQuery.Close;
  end;
  if pblRestartTransaction then
  begin

    restartTransaction(TSQLTransaction(poQuery.Transaction));
  end;
  poQuery.SQL.Clear;
  poQuery.Params.Clear;
  poQuery.SQL.Delimiter:=LF;
  poQuery.SQL.AddDelimitedText(psSQL);
end;


end.

