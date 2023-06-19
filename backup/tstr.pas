unit tstr;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

{** @abstract(Функция добавляет к концу строки разделитель, если его там нет)
    @param(psLine строковая переменная, содержащая путь. Передается по ссылке.)
    @returns(строка со слэшем в конце.)
    @code(slashIt(S)); }

const LF : Char = #10;
      CR : Char = #13;
      APOSTROPHE : Char = #39;
      PERCENT : Char = #37;

function addSeparator(psLine : String) : String;

{** @abstract(Функция проверяет, является ли строка пустой. Строка считается пустой,
              даже если она содержит пробелы)
    @param(psLine строковая переменная)
    @returns(@true, если строка пуста, иначе @false)
    @code(if isEmpty(S) then ...) }
function isEmpty(psLine : String) : Boolean;


implementation

function addSeparator(psLine: String): String;
var lsLine : String;
begin

  if not IsEmpty(psLine) then begin

    lsLine:=Trim(psLine);
    if lsLine[Length(lsLine)]<>DirectorySeparator then

      lsLine:=lsLine+DirectorySeparator;

  end;
  Result:=psLine;
end;


function isEmpty(psLine : String) : Boolean;
begin

  Result:=Length(Trim(psLine))=0;
end;

end.

