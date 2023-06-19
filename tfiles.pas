unit tfiles;


interface

uses SysUtils
     , tstr
     ;

type

{ TEasyFindFiles }
 TEasyFindFiles = class(TObject)
     private

       moSearchRec : TSearchRec;
       mblSearchOpen : Boolean;
     public

       constructor Create();
       function First(psFolder : String; psMask : String = '*.*'; piAttr : Integer = faAnyFile) : String;
       function Next : String;
       function Close : Boolean;
       function Get_Attr() : LongInt;
       destructor Destroy();
 end;


function IsFolderExists(psPath : String) : Boolean;
function Touch(psFileName : String; psContent : String='') : Boolean;


implementation

function IsFolderExists(psPath : String) : Boolean;
var loSearch : TSearchRec;
    liRes    : Integer;
    lsPath   : String;
begin

  lsPath:=addSeparator(psPath);
  lsPath:=lsPath+'*.*';
  liRes:=SysUtils.FindFirst(lsPath,faDirectory,loSearch);
  IsFolderExists:=(liRes=0);
  SysUtils.FindClose(loSearch);
end;

{ TEasyFindFiles }

constructor TEasyFindFiles.Create;
begin

  mblSearchOpen := False;
end;


function TEasyFindFiles.First(psFolder: String; psMask: String;
  piAttr: Integer): String;
var lsFilename : String;
    lsFolder : String;
begin

  Result:='';
  if not mblSearchOpen then
  begin

    lsFolder := addSeparator(psFolder);
    if FindFirst(lsFolder+psMask,piAttr,moSearchRec) = 0 then
    begin

      lsFileName := moSearchRec.Name;
      mblSearchOpen := True;
      while (lsFileName='.') or (lsFileName='..') do
      begin

        lsFileName := self.Next();
      end;
      if IOResult = 0 then
      begin

        Result:=lsFileName;
      end;
    end;
  end;
end;


function TEasyFindFiles.Next: String;
begin

  Result := '';
  if mblSearchOpen then
  begin

    if FindNext(moSearchRec) = 0 then
    begin

      if IOResult = 0 then
      begin

        Result := moSearchRec.Name;
      end;
    end;
  end;
end;


function TEasyFindFiles.Close: Boolean;
begin

  Result := False;
  if mblSearchOpen then
  begin

    SysUtils.FindClose(moSearchRec);
    if IOResult = 0 then
    begin

      Result:=True;
      mblSearchOpen:=False;
    end;
  end;
end;


function TEasyFindFiles.get_Attr: LongInt;
begin

  Result := moSearchRec.Attr;
end;


destructor TEasyFindFiles.Destroy;
begin

  inherited Destroy;
  if mblSearchOpen then

     self.Close();
end;


function Touch(psFileName : String; psContent : String='') : Boolean;
var lfFile : Text;
begin

  Result:=False;
  AssignFile(lfFile,psFileName);
  {$i-}
  Rewrite(lfFile);
  if IOResult = 0 then
  begin

    writeln(lfFile,psContent);
    Result:=IOResult = 0;
    CloseFile(lfFile);
  end;
end;


end.
