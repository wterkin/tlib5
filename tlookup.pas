unit tlookup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, StdCtrls,
  tdb
  ;

type TLookupIndexStyle=(lisID,lisGUID);

     TLookUpIndexRecord = Record

       msName  : String;
       miID    : Integer;
       msGUID  : String;
     end;

     { TEasyLookupCombo }
     TEasyLookupCombo = class(TObject)

       private

         maoLookupIndexRecordArray : array of TLookUpIndexRecord;
         moStyle     : TLookupIndexStyle;
         moComboBox  : TComboBox;
         moQuery     : TSQLQuery;
         msListField : String;
         msKeyField  : String;
         msSQL       : String;

       public

         //constructor create();
         procedure setComboBox(poCombo : TComboBox);
         procedure setQuery(poQuery : TSQLQuery);
         procedure setStyle(poStyle : TLookupIndexStyle);
         procedure setListField(psField : String);
         procedure setKeyField(psField : String);
         procedure setKey(piKeyValue : Integer);
         procedure setKey(psKeyValue : String);
         procedure setSQL(psSQL : String);
         { TO DO : Как передавать сюда условие выборки - в запросе или отдельно? }
         function  fill(pblWithCode : Boolean=False) : Boolean;
         function  getIntKey() : Integer; overload;
         function  getStringKey() : String; overload;
         destructor Destroy; override;
     end;

implementation

{ TEasyLookupCombo }
procedure TEasyLookupCombo.setStyle(poStyle: TLookupIndexStyle);
begin

  moStyle:=poStyle;
end;


procedure TEasyLookupCombo.setListField(psField: String);
begin

  msListField:=psField;
end;


procedure TEasyLookupCombo.setKeyField(psField: String);
begin

  msKeyField:=psField;
end;


procedure TEasyLookupCombo.setComboBox(poCombo: TComboBox);
begin

  moComboBox:=poCombo;
end;


procedure TEasyLookupCombo.setQuery(poQuery: TSQLQuery);
begin

  moQuery:=poQuery;
end;


procedure TEasyLookupCombo.setSQL(psSQL : String);
begin

  msSQL:=psSQL;
end;


function TEasyLookupCombo.fill(pblWithCode: Boolean) : Boolean;
var liIdx : Integer;
begin

  Result:=True;
  initializeQuery(moQuery,msSQL);
  try

    moQuery.Open;
  except

    Result:=False;
  end;

  if Result then
  begin

    moComboBox.Items.Clear;
    moQuery.Last;
    if moQuery.RecordCount>0 then
    begin

      SetLength(maoLookupIndexRecordArray,0);
      SetLength(maoLookupIndexRecordArray,moQuery.RecordCount);
      liIdx:=0;
      moComboBox.Items.Clear;
      moQuery.First;
      while not moQuery.Eof do begin

        maoLookupIndexRecordArray[liIdx].msName:=
          moQuery.FieldByName(msListField).AsString;
        if moStyle=lisID then
          maoLookupIndexRecordArray[liIdx].miID:=
            moQuery.FieldByName(msKeyField).AsInteger
        else
          if moStyle=lisGUID then
            maoLookupIndexRecordArray[liIdx].msGUID:=
              moQuery.FieldByName(msKeyField).AsString;

        if pblWithCode then
          moComboBox.Items.Add('<'+IntToStr(maoLookupIndexRecordArray[liIdx].miID)+
            '> '+maoLookupIndexRecordArray[liIdx].msName)
        else
          moComboBox.Items.Add(maoLookupIndexRecordArray[liIdx].msName);
        inc(liIdx);
        moQuery.Next;
      end;
      moComboBox.ItemIndex:=0;
    end else
    begin

      moComboBox.ItemIndex:=-1;
    end;
  end;
end;


function TEasyLookupCombo.getIntKey(): Integer;
begin

  Result:=-1;
  if moComboBox.ItemIndex>=0 then
  begin

    Result:=maoLookupIndexRecordArray[moComboBox.ItemIndex].miID;
  end;
end;


destructor TEasyLookupCombo.Destroy;
begin

  SetLength(maoLookupIndexRecordArray,0);
  moComboBox.Items.Clear;
  inherited;
end;


function TEasyLookupCombo.getStringKey(): String;
begin

  Result:='';
  if moComboBox.ItemIndex>=0 then
  begin

    Result:=maoLookupIndexRecordArray[moComboBox.ItemIndex].msGUID;
  end;
end;


procedure TEasyLookupCombo.setKey(piKeyValue: Integer);
var liIdx : Integer;
begin

  moComboBox.ItemIndex:=-1;
  for lIIdx:=Low(maoLookupIndexRecordArray) to High(maoLookupIndexRecordArray) do
  begin

    if maoLookupIndexRecordArray[liIdx].miID=piKeyValue then
    begin

      moComboBox.ItemIndex:=liIdx;
      break;
    end;
  end;
end;


procedure TEasyLookupCombo.setKey(psKeyValue: String);
var liIdx : Integer;
begin

  moComboBox.ItemIndex:=-1;
  for lIIdx:=Low(maoLookupIndexRecordArray) to High(maoLookupIndexRecordArray) do
  begin

    if maoLookupIndexRecordArray[liIdx].msGUID=psKeyValue then
    begin

      moComboBox.ItemIndex:=liIdx;
      break;
    end;
  end;
end;


end.

