unit tini;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles,  Forms, LazFileUtils, Controls, Graphics
  , DBGrids
  , tapp, tstr, tlib
  ;

const csColumnVisibilitySuffix = '.visible';


type

{ TIniManager }
 TEasyIniManager = class(TObject)

     private

       moIniFile : TIniFile;
       msFileName : String;
     public

       constructor Create(psIniFile : String = '');
       destructor Done();
       procedure write(psSection, psName: String; psValue : String); overload;
       procedure write(psSection, psName: String; piValue : Integer); overload;
       procedure write(psSection, psName: String; pblValue : Boolean); overload;
       procedure write(psSection, psName: String; pdtValue : TDateTime); overload;
       procedure write(psSection, psName: String; pfValue : Real); overload;
       procedure write(psSection, psName : String; poFont : TFont);
       procedure write(poForm : TForm); overload;
       procedure write(poGrid : TDBGrid); overload;
       function read(psSection, psName:String; psDefault : String) : String; overload;
       function read(psSection, psName: String; piDefault : Integer) : Integer; overload;
       function read(psSection, psName: String; pblDefault : Boolean) : Boolean; overload;
       function read(psSection, psName: String; pdtDefault : TDateTime) : TDateTime; overload;
       function read(psSection, psName: String; pfDefault : Real) : Real; overload;
       function read(psSection, psName : String; poDefault : TFont) : TFont; overload;
       procedure read(poForm : TForm); overload;
       procedure read(poGrid : TDBGrid); overload;
     end;

implementation

{ TEasyIniManager }

constructor TEasyIniManager.Create(psIniFile: String);
begin

  if isEmpty(psIniFile) then
  begin

    msFileName := ExtractFileNameWithoutExt(Application.Exename) + '.ini';
  end else
  begin

    msFileName := psIniFile;
  end;
  moIniFile := TIniFile.Create(msFileName);
end;


destructor TEasyIniManager.Done;
begin

  FreeAndNil(moIniFile);
end;


procedure TEasyIniManager.write(psSection, psName: String; piValue: Integer);
begin

  moIniFile.writeInteger(psSection, psName, piValue);
end;


procedure TEasyIniManager.write(psSection, psName: String; pblValue: Boolean);
begin

  moIniFile.WriteBool(psSection, psName, pblvalue);
end;


procedure TEasyIniManager.write(psSection, psName: String; pdtValue: TDateTime);
begin

  moIniFile.WriteDateTime(psSection, psName, pdtValue);
end;


procedure TEasyIniManager.write(psSection, psName: String; pfValue: Real);
begin

  moIniFile.WriteFloat(psSection, psName, pfValue);
end;


procedure TEasyIniManager.write(psSection, psName: String; psValue: String);
begin

  moIniFile.writeString(psSection, psName, psValue);
end;


procedure TEasyIniManager.write(psSection, psName : String; poFont : TFont);
begin

  write(psSection,psName,SerializeFont(poFont));
end;


procedure TEasyIniManager.write(poForm: TForm);
begin

  moIniFile.WriteInteger(poForm.Name,'Left',poForm.Left);
  moIniFile.WriteInteger(poForm.Name,'Top',poForm.Top);
  if (poForm.BorderStyle=bsSizeable) or
     (poForm.BorderStyle=bsSizeToolWin) then
  begin

    moIniFile.WriteInteger('Form','Width',poForm.Width);
    moIniFile.WriteInteger('Form','Height',poForm.Height);
  end;
end;


procedure TEasyIniManager.write(poGrid: TDBGrid);
var liIdx    : Integer;
    loColumn : TColumn;
begin

  for liIdx:=0 to Pred(poGrid.Columns.Count) do
  begin

    loColumn:=poGrid.Columns.Items[liIdx] as TColumn;
    if loColumn.FieldName<>'' then
    begin

      write(poGrid.Name, loColumn.FieldName, loColumn.Width);
      if loColumn.Visible then
      begin

        write(poGrid.Name, loColumn.FieldName+csColumnVisibilitySuffix, 1)
      end else
      begin

        write(poGrid.Name, loColumn.FieldName+csColumnVisibilitySuffix, 0);
      end;
    end;
  end;
end;


function TEasyIniManager.read(psSection, psName, psDefault: String): String;
begin

  Result := moIniFile.ReadString(psSection, psName, psDefault);
end;


function TEasyIniManager.read(psSection, psName: String; piDefault: Integer
			): Integer;
begin

  Result := moIniFile.ReadInteger(psSection, psName, piDefault);
end;


function TEasyIniManager.read(psSection, psName: String; pblDefault: Boolean
			): Boolean;
begin

  Result := moIniFile.ReadBool(psSection, psName, pblDefault);
end;


function TEasyIniManager.read(psSection, psName: String; pdtDefault: TDateTime
			): TDateTime;
begin

  Result := moIniFile.ReadDateTime(psSection, psName, pdtDefault);
end;


function TEasyIniManager.read(psSection, psName: String; pfDefault: Real): Real;
begin

  Result := moIniFile.ReadFloat(psSection, psName, pfDefault);
end;


function TEasyIniManager.read(psSection, psName : String; poDefault : TFont) : TFont;
var lsLine : String;
    loFont : TFont;
begin

  loFont := TFont.Create();
  lsLine:=read(psSection,psName,'');
  if isEmpty(lsLine) then
  begin

    loFont := poDefault;
  end else
  begin

    DeSerializeFont(loFont,lsLine);
	end;
  Result := loFont;
end;


procedure TEasyIniManager.read(poForm: TForm);
begin

  if FileExists(msFileName) then
  begin

    poForm.Left:=moIniFile.ReadInteger(poForm.Name,'Left',poForm.Left);
    poForm.Top:=moIniFile.ReadInteger(poForm.Name,'Top',poForm.Top);
    if (poForm.BorderStyle=bsSizeable) or
       (poForm.BorderStyle=bsSizeToolWin) then
    begin

      poForm.Width:=moIniFile.ReadInteger('Form','Width',poForm.Width);
      poForm.Height:=moIniFile.ReadInteger('Form','Height',poForm.Height);
    end;
  end;
end;


procedure TEasyIniManager.read(poGrid: TDBGrid);
var liIdx    : Integer;
    loColumn : TColumn;
begin

  for liIdx:=0 to Pred(poGrid.Columns.Count) do
  begin

    loColumn:=poGrid.Columns.Items[liIdx] as TColumn;
    if loColumn.FieldName<>'' then
    begin

      loColumn.Width:=read(poGrid.Name,loColumn.FieldName,
                           poGrid.Columns.Items[liIdx].Width);
      loColumn.Visible:=(read(poGrid.Name,loColumn.FieldName+
                              csColumnVisibilitySuffix,1)=1);
    end;
  end;
end;


end.

