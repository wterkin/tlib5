unit tini;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles,  Forms, LazFileUtils, Controls

  , tapp
  ;

type

{ TIniManager }

 TIniManager = class(TObject)

     private

       moIniFile : TIniFile;
       msFileName : String;
     public

       constructor Create();
       destructor Done();
       procedure SaveForm(poForm : TForm);
       procedure LoadForm(poForm : TForm);
     end;

implementation

{ TIniManager }

constructor TIniManager.Create;
begin

  msFileName := ExtractFileNameWithoutExt(Application.Exename) + '.ini';
  moIniFile := TIniFile.Create(msFileName);
  moIniFile;
end;


destructor TIniManager.Done;
begin

  FreeAndNil(moIniFile);
end;


procedure TIniManager.SaveForm(poForm: TForm);
begin

  moIniFile.WriteInteger('Form','Left',poForm.Left);
  moIniFile.WriteInteger('Form','Top',poForm.Top);
  if (poForm.BorderStyle=bsSizeable) or
     (poForm.BorderStyle=bsSizeToolWin) then begin

    moIniFile.WriteInteger('Form','Width',poForm.Width);
    moIniFile.WriteInteger('Form','Height',poForm.Height);
  end;
end;


procedure TIniManager.LoadForm(poForm: TForm);
begin

  if FileExists(msFileName) then
  begin

    poForm.Left:=moIniFile.ReadInteger('Form','Left',poForm.Left);
    poForm.Top:=moIniFile.ReadInteger('Form','Top',poForm.Top);
    if (poForm.BorderStyle=bsSizeable) or
       (poForm.BorderStyle=bsSizeToolWin) then begin

      poForm.Width:=moIniFile.ReadInteger('Form','Width',poForm.Width);
      poForm.Height:=moIniFile.ReadInteger('Form','Height',poForm.Height);
    end;
  end;
end;


end.

