unit tlib;

interface

uses Sysutils, Graphics, Process
  , tstr
  ;

const csFontDelimiter = ';';

function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: Integer): Integer; overload;
function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: Double): Double; overload;
function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: String): String; overload;
function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: Variant): Variant; overload;
function serializeFont(poFont : TFont) : String;
procedure deserializeFont(poFont : TFont; psLine : String);
procedure EasyExec(psProgramm, psArguments : String; pblWait : Boolean = False; pblHideWindow : Boolean = False);


implementation

function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: Integer): Integer;
begin

  if ACondition then

    Result := ATrueResult
  else

    Result := AFalseResult;
end;


function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: Double): Double;
begin

  if ACondition then

    Result := ATrueResult
  else

    Result := AFalseResult;
end;


function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: string): string;
begin

  if ACondition then

    Result := ATrueResult
  else

    Result := AFalseResult;
end;


function iif(const ACondition: Boolean; const ATrueResult, AFalseResult: variant): variant;
begin

  if ACondition then

    Result := ATrueResult
  else

    Result := AFalseResult;
end;


function serializeFont(poFont : TFont) : String;
var liStyle : Integer;
begin

  with poFont do begin

    Result:=Name+csFontDelimiter+
            IntToStr(CharSet)+csFontDelimiter+
            IntToStr(Height)+csFontDelimiter;
    case Pitch of

      fpDefault : Result:=Result+'D'+csFontDelimiter;
      fpVariable: Result:=Result+'V'+csFontDelimiter;
      fpFixed   : Result:=Result+'F'+csFontDelimiter;
    end;
    Result:=Result+IntToStr(Size)+csFontDelimiter;
    liStyle:=0;
    if Style*[fsBold]<>[] then liStyle:=liStyle or 1;
    if Style*[fsItalic]<>[] then liStyle:=liStyle or 2;
    if Style*[fsUnderline]<>[] then liStyle:=liStyle or 4;
    if Style*[fsStrikeOut]<>[] then liStyle:=liStyle or 8;
    Result:=Result+IntToStr(liStyle);
  end;
end;


procedure deserializeFont(poFont : TFont; psLine : String);
var lsLine,
    liCode  : String;
    liPos,
    liStyle : Integer;
begin

  lsLine:=psLine;
  if not IsEmpty(Trim(lsLine)) then
  begin

    {---< Имя шрифта >---}
    liPos:=Pos(csFontDelimiter,lsLine);
    if liPos>0 then
    begin

      poFont.Name:=Cut(lsLine,1,Pred(liPos));
      Delete(lsLine,1,1);

      {---< Чарсет >---}
      liPos:=Pos(csFontDelimiter,lsLine);
      if liPos>0 then
      begin

        poFont.Charset:=StrToIntDef(Cut(lsLine,1,Pred(liPos)),1);
        Delete(lsLine,1,1);

        {---< Высота >---}
        liPos:=Pos(csFontDelimiter,lsLine);
        if liPos>0 then
        begin

          poFont.Height:=StrToIntDef(Cut(lsLine,1,Pred(liPos)),1);
          Delete(lsLine,1,1);

          {---< Pitch >---}
          liPos:=Pos(csFontDelimiter,lsLine);
          if liPos>0 then
          begin

            liCode:=Cut(lsLine,1,Pred(liPos));
            case liCode[1] of

              'D': poFont.Pitch:=fpDefault;
              'V': poFont.Pitch:=fpVariable;
              'F': poFont.Pitch:=fpFixed;
            end;
            Delete(lsLine,1,1);

            {---< Размер >---}
            liPos:=Pos(csFontDelimiter,lsLine);
            if liPos>0 then
            begin

              poFont.Size:=StrToIntDef(Cut(lsLine,1,Pred(liPos)),1);
              Delete(lsLine,1,1);

              {---< Стиль >---}
              liStyle:=StrToIntDef(lsLine,3);
              poFont.Style:=[];
              if liStyle and 1 = 1 then
              begin

                poFont.Style:=poFont.Style+[fsBold];
							end;
							if liStyle and 2 = 2 then
              begin

  							poFont.Style:=poFont.Style+[fsItalic];
							end;
              if liStyle and 4 = 4 then
              begin

                poFont.Style:=poFont.Style+[fsUnderline];
							end;
              if liStyle and 8 = 8 then
              begin

                poFont.Style:=poFont.Style+[fsStrikeOut];
							end;
            end;
          end;
        end;
      end;
    end;
  end;
end;


procedure EasyExec(psProgramm, psArguments : String; pblWait : Boolean = False; pblHideWindow : Boolean = False);
var loProc : TProcess;
begin

  loProc:=TProcess.Create(nil);
  loProc.Executable:=psProgramm;
  loProc.Parameters.Add(psArguments);

  if pblWait then
    loProc.Options:=loProc.Options + [poWaitOnExit];

  if pblHideWindow then
  begin

    loProc.ShowWindow:=swoHide;
    loProc.StartupOptions:=loProc.StartupOptions+[suoUseShowWindow];
  end;
  loProc.Execute;
  FreeAndNil(loProc);
end;


end.
