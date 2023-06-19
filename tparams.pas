unit tparams;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

{ TArgumentAnalyzer }

 TEasyParameters = class (TObject)
        private

          miParamCount  : Integer;
          macParameters : Array of Char;
          masArguments  : Array of String;
        public

          constructor Create();
          function indexOf(psParamName : String) : Integer;
          function isParam(psParamName : String) : Boolean;
          function getParamArgument(psParamName : String) : String;
          function isEmpty() : Boolean;
          destructor Destroy(); override;
     end;

const ccParamDelimiter1='/';
      ccParamDelimiter2='-';
      ccArgDelimiter=':';

implementation


constructor TEasyParameters.Create();
var liIdx   : Integer;
    lsParam : String;
begin

  inherited;
  //***** Параметры вообще есть?
  miParamCount:=ParamCount();
  if miParamCount>0 then
  begin

    SetLength(macParameters,miParamCount);
    //FillChar(macParameters,miParamCount,'');
    SetLength(masArguments, miParamCount);
    //FillChar(masArguments,miParamCount,'');
    //***** Переберем их
    for liIdx:=1 to miParamCount do
    begin

      lsParam:=AnsiUpperCase(Trim(ParamStr(liIdx)));
      //***** Есть ли тут наши параметры?
      if (Pos(ccParamDelimiter1,lsParam)>0) or
         (Pos(ccParamDelimiter2,lsParam)>0) then
      begin

        //***** Есть, отлично. А есть буква за разделителем?
        if Length(lsParam)>1 then
        begin

          //***** Есть, сохраняем её как ключ
          macParameters[Pred(liIdx)]:=lsParam[2];

          //***** Может, есть и аргументы у этого ключа?
          {$B-}
          if (Length(lsParam)>2) and (lsParam[3]=ccArgDelimiter) then
          begin

            //***** Видимо, есть. Откусываем начало строки и сохраняем в аргумент
            lsParam:=Trim(ParamStr(liIdx)); //для линукса
            Delete(lsParam,1,3);
            masArguments[Pred(liIdx)]:=lsParam;
          end;
        end;
      end;
    end;
  end;
end;


function TEasyParameters.indexOf(psParamName : String) : Integer;
var liIdx       : Integer;
    lsParamName : String;
begin

  Result:=-1;
  lsParamName:=AnsiUpperCase(Trim(psParamName));
  for liIdx:=1 to miParamCount do
  begin

    if macParameters[Pred(liIdx)]=lsParamName[1] then
    begin

      Result:=liIdx;
      break;
    end;
  end;
end;


function TEasyParameters.isParam(psParamName : String) : Boolean;
begin

  Result:=IndexOf(psParamName)>=0;
end;


function TEasyParameters.getParamArgument(psParamName : String) : String;
var liIdx : Integer;
begin

  Result:='';
  liIdx:=IndexOf(psParamName);
  if liIdx>=0 then
  begin

    Result:=masArguments[Pred(liIdx)];
  end;
end;


function TEasyParameters.isEmpty: Boolean;
begin

  Result:=miParamCount=0;
end;


destructor TEasyParameters.Destroy();
begin

  SetLength(macParameters,0);
  SetLength(masArguments,0);
  inherited;
end;


end.

