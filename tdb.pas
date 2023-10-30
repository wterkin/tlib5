unit tdb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db
  , tstr
  ;

type  TDBMode  = (dmInsert,dmUpdate,dmView);
      TDBState = (dbsClosed,dbsOpen);


procedure initializeQuery(poQuery : TSQLQuery; psSQL : String; pblRestartTransaction : Boolean = True);

procedure restartTransaction(poTransaction : TSQLTransaction);


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
  //poQuery.SQL.Delimiter:=CR;
  poQuery.SQL.AddDelimitedText(psSQL, #13, True);
end;


procedure restartTransaction(poTransaction : TSQLTransaction);
begin

  poTransaction.EndTransaction;
  poTransaction.StartTransaction;
end;


end.

