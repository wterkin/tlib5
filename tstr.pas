unit tstr;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8
  ;


const LF : Char = #10;
      CR : Char = #13;
      CRLF : String = #10#13;
      APOSTROPHE : Char = #39;
      PERCENT : Char = #37;
      ciAlLeft          = 1;
      ciAlRight         = 2;
      ciAlCenter        = 3;

{** @abstract(Функция добавляет к концу строки разделитель, если его там нет)
    @param(psLine строковая переменная, содержащая путь. Передается по ссылке.)
    @returns(строка со слэшем в конце.)
    @code(addSeparator(S)); }
function addSeparator(psLine : String) : String;

{** @abstract(Универсальная функция выравнивания строки.)
    @param(psLine строка для выравнивания)
    @param(piWidth нужная ширина строки)
    @param(piAlign флаг выравнивания - ciAlLeft, ciAlRight,ciAlCenter)
    @param(pcFill символ заполнения, по умолчанию пробел)
    @returns(выровненная строка)
    @code(s:=alignFill('0,0',6,ciAlRight,'0');) }
function alignFill(psLine : String; piWidth : Integer; piAlign : Integer = ciAlLeft; pcFill : Char=#32) : String;

{** @abstract(Функция выравнивания строки вправо)
    @param(psLine строка для выравнивания)
    @param(piWidth нужная ширина строки)
    @param(pcFill символ заполнения, по умолчанию пробел)
    @returns(выровненная строка)
    @code(s:=alignRight('283,61',6);) }
function alignRight(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;

{** @abstract(Функция выравнивания строки влево)
    @param(psLine строка для выравнивания)
    @param(piWidth нужная ширина строки)
    @param(pcFill символ заполнения, по умолчанию пробел)
    @returns(выровненная строка)
    @code(s:=alignLeft('946,52',8,'0');) }
function alignLeft(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;

{** @abstract(Функция выравнивания строки по центру)
    @param(psLine строка для выравнивания)
    @param(piWidth нужная ширина строки)
    @param(pcFill символ заполнения, по умолчанию пробел)
    @returns(выровненная строка)
    @code(s:=alignCenter('Тру-ля-ля',15);) }
function alignCenter(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;

function backPos(cSymbol: Char; sLine : String) : Integer;

function cut(var psLine : String; piFrom : Integer; piHowMany : Integer=-1) : String;

function deleteSubstr(sInputLine : String; sSubstr : String; iCount : Integer = 1) : String;

function deleteTail(psLine : String; piCount : Integer = 1) : String;

function hex2int(psHex : string) : LongInt;

{** @abstract(Функция проверяет, является ли строка пустой. Строка считается пустой,
              даже если она содержит пробелы)
    @param(psLine строковая переменная)
    @returns(@true, если строка пуста, иначе @false)
    @code(if isEmpty(S) then ...) }
function isEmpty(psLine : String) : Boolean;

{** @abstract(Функция убирает концевые пробелы строки и приводит ее к верхнему регистру)
    @param(psLine исходная строка)
    @returns(строка без концевых пробелов, приведенную к верхнему регистру)
    @code(s:=upperTrimLine('   Вот такая вот... загогулина.    ')); }
function upperTrimLine(psLine : String) : String;






implementation


function addSeparator(psLine: String): String;
var lsLine : String;
begin

  if not IsEmpty(psLine) then
  begin

    lsLine:=Trim(psLine);
    if lsLine[UTF8Length(lsLine)]<>DirectorySeparator then
    begin

      lsLine:=lsLine+DirectorySeparator;
		end;
  end;
  Result:=lsLine;
end;



function alignFill(psLine : String; piWidth : Integer; piAlign : Integer = ciAlLeft; pcFill : Char = ' ') : String;
var lsLine  : String;
    liWdt,
    liLen,
    liHalf  : Integer;
begin

  lsLine:=Trim(psLine);
  liLen:=Length(lsLine);
  if liLen>0 then begin

    if liLen<piWidth then begin

      liWdt:=piWidth-liLen;
      if piAlign=ciAlCenter then begin

        liHalf:=liWdt div 2;
        lsLine:=StringOfChar(pcFill,liHalf)+lsLine+StringOfChar(pcFill,liWdt-liHalf);
      end else begin

        if piAlign=ciAlLeft then begin

          lsLine:=lsLine+StringOfChar(pcFill,liWdt);
        end else begin

          if piAlign=ciAlRight then begin

            lsLine:=StringOfChar(pcFill,liWdt)+lsLine;
          end;
        end
      end;
    end;
  end else begin

    lsLine:=StringOfChar(#32,piWidth);
  end;
  Result:=lsLine;
end;


function alignRight(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;
begin

  Result:=AlignFill(psLine,piWidth,ciAlRight,pcFill);
end;


function alignLeft(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;
begin

  Result:=AlignFill(psLine,piWidth,ciAlLeft,pcFill);
end;


function alignCenter(psLine : String; piWidth : Integer; pcFill : Char = #32) : String;
begin

  Result:=AlignFill(psLine,piWidth,ciAlCenter,pcFill);
end;


function backPos(cSymbol: Char; sLine : String) : Integer;
var iLen : Integer;
    iChar : Integer;
begin

  Result := -1;
  iLen := UTF8Length(sLine);
  for iChar := iLen downto 1 do
  begin

    if sLine[iChar] = cSymbol then
    begin

      Result := iChar;
      break;
    end;
  end;
end;

function cut(var psLine : String; piFrom : Integer; piHowMany : Integer=-1) : String;
var liLen : Integer;
begin

  liLen:=Length(psLine);
  if (piFrom<1) or (piFrom>liLen) then
  begin

    piFrom:=1;
  end;
  if (piHowMany<1) or (piHowMany+piFrom>liLen) then
  begin

    piHowMany:=Succ(liLen-piFrom);
  end;
  if piHowMany>0 then
  begin

    Result:=Copy(psLine,piFrom,piHowMany);
    Delete(psLine,piFrom,piHowMany);
  end;
end;

function deleteTail(psLine : String; piCount : Integer = 1) : String;
var lsLine : String;
begin

  lsLine:=psLine;
  if piCount>=1 then
  begin

    if (piCount>=UTF8Length(psLine)) then
    begin

      lsLine:='';
    end else
    begin

      UTF8Delete(lsLine,UTF8Length(lsLine)-Pred(piCount),piCount);
    end;
  end;
  Result:=lsLine;
end;


function deleteSubstr(sInputLine : String; sSubstr : String; iCount : Integer = 1) : String;
var sLine : String;
    iPosition : Integer;
begin

  sLine := sInputLine;
  iPosition := UTF8Pos(sSubstr, sLine);
  while iPosition > 0 do
  begin

    UTF8Delete(sLine, iPosition, iCount);
    iPosition := UTF8Pos(sSubstr, sLine);
  end;
  Result:=sLine;
end;


function isEmpty(psLine : String) : Boolean;
begin

  Result:=UTF8Length(Trim(psLine))=0;
end;      


function upperTrimLine(psLine : String) : String;
begin

  Result:=UTF8UpperCase(Trim(psLine));
end;

function hex2int(psHex : String) : LongInt;
begin

  if (psHex <> '') and (psHex[1] <> '$') then

    result := strToInt('$' + psHex)
  else

    result := strToInt(psHex);
end;


function EasyCopy(var psLine : String; piFrom : Integer; piHowMany : Integer; pblCut : Boolean = False) : String;
var liLen   : Integer;
    liPos   : Integer;
    liCount : Integer;
begin

  Result := '';
  liLen:=UTF8Length(psLine);
  // *** Если номер начального символа по модулю меньше длины...
  if Abs(piFrom) < liLen then 
  begin

    // *** Если нужно отсчитывать с конца...
    if piFrom < 0 then 
    begin

      // *** Складываем номер символа с длиной строки + 1
      //     получаем позицию символа от начала строки
      liPos := liLen + piFrom + 1;
      
    end else
    begin

      liPos := piFrom;
    end;
  end;
  liCount := Abs(piHowMany);
  if (liCount >= 1) and (liPos + liCount > liLen) then begin
  
    Result := UTF8Copy(psLine, liPos, liCount);
    if pblCut then
    begin

      UTF8Delete(psLine, liPos, liCount);
    end;
  end;
end;


end.

