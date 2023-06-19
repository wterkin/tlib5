unit tgrids;

{$mode ObjFPC}{$H+}

interface

uses Classes, SysUtils, dbgrids

  ;

type

  { TEasyGrid }

  TEasyGrid = class(TObject)

    private

		  moGrid : TDBGrids;
		public

		  constructor Create(poGrid : TDBGrid);
      procedure adjustFontSize(piDelta: Integer; piMinimalFontSize : Integer = 7);
      function getFieldLen(piField : Integer) : Integer;
      procedure populate(pasGridFields, pasGridTitles : Array of String;
                         pasGridAlignments : Array of TAlignment);
      procedure resetColumnsWidth(piWidth : Integer);
  end;
implementation


{ TEasyGrid }

constructor TEasyGrid.Create(poGrid: TDBGrid);
begin

  moGrid := poGrid;
end;


procedure TEasyGrid.resetColumnsWidth(piWidth : Integer);
var liColumn : Integer;
    loColumn : TColumn;
begin

  for liColumn := 0 to Pred(moGrid.Columns.Count) do
  begin

    loColumn := moGrid.Columns.Items[liColumn] as TColumn;
    if loColumn.FieldName <> '' then begin

      loColumn.Width := piWidth;
    end;
  end;
end;


procedure TEasyGrid.adjustFontSize(piDelta: Integer; piMinimalFontSize : Integer = 7);
var liStep : Integer;
begin

  liStep := (piDelta div 120);
  if (moGrid.Font.Size + liStep) > piMinimalFontSize then
  begin

    moGrid.BeginUpdate();
    moGrid.Font.Size:=poGrid.Font.Size + liStep;
    moGrid.DefaultRowHeight := moGrid.Canvas.TextHeight('АБВГДЕ') + 4;
    moGrid.EndUpdate();
  end;
end;


procedure TEasyGrid.populate(pasGridFields, pasGridTitles : Array of String;
                             pasGridAlignments : Array of TAlignment);
var liColumn : Integer;
    loColumn : TColumn;
begin

  moGrid.Columns.Clear;
  for liColumn := Low(pasGridFields) to High(pasGridFields) do
  begin

    loColumn := moGrid.Columns.Add;
    loColumn.FieldName := pasGridFields[liColumn];
    loColumn.Title.Caption := pasGridTitles[liColumn];
    loColumn.Alignment := pasGridAlignments[liColumn];
  end;
end;


function TEasyGrid.getFieldLen(piField : Integer) : Integer;
var liStrLen, liTitleLen : Integer;
    loColumn : TColumn;
begin

  loColumn := moGrid.Columns[piField];
  if loColumn.Field = Nil then
  begin

    raise TExceptionClass.Create('*** Поле '+loColumn.FieldName+' отсутствует в выборке!');
	end;
  liStrLen := Length(Trim(loColumn.Field.AsString));
  liTitleLen := Length(moGrid.Columns[piField].Title.Caption);
  if liStrLen < liTitleLen then
  begin

    Result := liTitleLen
	end else
  begin

    Result := liStrLen;
	end;
end;

procedure TEasyGrid.calculateColumnsWidth();


var liField : Integer;
    liSumWidth : Integer;
    liStrLen : Integer;
    lrCoeff  : Real;
    lrWidth  : Real;
begin

  liSumWidth:=0;
  for liField:=0 to poGrid.Columns.Count-1 do
    liSumWidth:=liSumWidth+getfieldLen(poGrid,liField);
  //liSumWidth:=poGrid.Width;
  lrCoeff:=Real(poGrid.Width)/Real(liSumWidth);

  for liField:=0 to poGrid.Columns.Count-1 do
  begin

    liStrLen:=getfieldLen(poGrid,liField);
    //lrCoeff:=Real(liStrLen)/Real(liSumWidth);
    lrWidth:=Real(liStrLen)*lrCoeff;//Real(poGrid.Width)*lrCoeff;
    poGrid.Columns[liField].Width:=Round(lrWidth)-(32 div poGrid.Columns.Count);
  end;
  if poGrid.Columns.Count mod 2 >0 then
    poGrid.Columns[liField].Width:=poGrid.Columns[liField].Width-2;
end;


function sortQueryBySelectedColumn(var poColumn : TColumn; var poLastColumn : TColumn;
                                   psColumnOrder : String) : String;
var lsTitle     : String;
    lsLastTitle : String;
begin

  lsTitle:=poColumn.Title.Caption;

  //***** Уже есть какая-то сортировка по этому полю?
  case poColumn.Tag of

    //***** Прямая сортировка. Переходим на обратную. Тот же столбец
    ciAscendOrder :
    begin

      psColumnOrder:=poColumn.FieldName+' DESC';
      poColumn.Tag:=ciDescentOrder;
      Delete(lsTitle,1,1);
      lsTitle:=ccUTF8DescendOrderChar+lsTitle;
      poLastColumn:=poColumn;
    end;

    //***** Обратная сортировка. Отключаем сортивку совсем. Тот же столбец
    ciDescentOrder :
    begin

      psColumnOrder:='';
      poColumn.Tag:=ciNoOrder;
      Delete(lsTitle,1,1);
      poLastColumn:=Nil;
    end;

    //***** Никакой сортировки. Включаем прямую. Новый столбец.
    ciNoOrder :
    begin

      if poLastColumn<>Nil then
      begin

        lsLastTitle:=poLastColumn.Title.Caption;
        Delete(lsLastTitle,1,1);
        poLastColumn.Title.Caption:=lsLastTitle;
        poLastColumn.Tag:=ciNoOrder;
      end;
      psColumnOrder:=poColumn.FieldName;
      poColumn.Tag:=ciAscendOrder;
      lsTitle:=ccUTF8AscendOrderChar+lsTitle;
      poLastColumn:=poColumn;
    end;
  end;
  poColumn.Title.Caption:=lsTitle;
  Result:=psColumnOrder;
end;

end.

