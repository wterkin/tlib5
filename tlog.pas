// TLibrary ver 3.5 by Pakhomenkov. A. P. pakhomenkov.ap@yandex.ru 2011
unit tlog;


interface


uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, Process
  , tstr
  //tlib,tstr,tsys{,twin}
  ;

  
type

  { TEasyLog }

  TEasyLog  = class(TObject)
    private

      moList      : TStringList;
      msLogName   : String;
      mblCrypted  : Boolean;
      mblSaved    : Boolean;
      msKey       : String;
      msLine      : String;
      mblLocked   : Boolean;
      msLogFolder : String;
      //function TimeStamp : String;

    public

      procedure BackSpace(piNum : Integer = 1);
      constructor Create(psLogName : String; pblCrypted : Boolean = False; psKey : String='');
      destructor Destroy; override;
      function IsSaved : Boolean;
      procedure Save;
      procedure Show(psProgram : String);
      procedure Write(psLine : String);
      procedure WriteInt(piValue : Longint);
      procedure WriteDate(pdtValue : TDateTime);
      procedure WriteError(psCode, psMsg : String);
      procedure WriteBool(pblValue : Boolean);
      procedure WriteLN(psLine : String = '');
      procedure WriteReal(prValue : Real);
      procedure WriteTimeStamp(lsMask : String='yyyy.MM.dd.hh.mm.ss');
      function  IsEmpty : Boolean;
      function  IsNewLine : Boolean;
      constructor Load(psLogName : String; pblCrypted : Boolean = False; psKey : String = '');
      procedure Reset;
      procedure Lock(pblLockState : Boolean = True);
      function  IsLocked : Boolean;
      function  getCount() : Integer;

  end;


const csDefaultKey = 'Не читайте на ночь советских газет';



  
implementation


{
function TEasyLog.TimeStamp : String;
begin

  msLogName:=Copy(msLogName,1,Pred(FindExtension(msLogName)))+'_'+
    DateTimeToFileName(Now)+
    ExtractFileExt(msLogName);
  Result:=msLogName;
end;
}


{ TEasyLog }
procedure TEasyLog.BackSpace(piNum : Integer);
begin

  msLine:=DeleteTail(msLine,piNum);
end;


constructor TEasyLog.Create(psLogName: String; pblCrypted : Boolean = False; psKey : String = '');
begin

  inherited create;
  moList:=TStringList.Create;
  msLogFolder:=ExtractFilePath(psLogName);
  addSeparator(msLogFolder);
  msLogName:=ExtractFileName(psLogName);
  mblCrypted:=pblCrypted;
  mblSaved:=True;
  if tstr.IsEmpty(psKey) then
    msKey:=csDefaultKey
  else
    msKey:=psKey;  
end;


destructor TEasyLog.Destroy;
begin

  Self.WriteLN;
  if not IsSaved then
    Save;
  FreeAndNil(moList);
  inherited;
end;


function TEasyLog.getCount : Integer;
begin

  Result:=moList.Count;
end;


function TEasyLog.IsSaved : Boolean;
begin

  Result:=mblSaved;
end;


procedure TEasyLog.Save;
begin

  if not IsLocked and not IsEmpty then begin
  
    moList.SaveToFile(msLogFolder+msLogName);
    mblSaved:=True;
  end;
end;


procedure TEasyLog.Show(psProgram : String) ;
var lsOutput : String;
begin

  if not IsSaved then
  begin

     Save;
	end;
	RunCommand(psProgram,[msLogFolder+msLogName],lsOutput);
end;


procedure TEasyLog.Write(psLine : String);
begin

  msLine:=msLine+psLine+' ';
end;


procedure TEasyLog.WriteInt(piValue : Longint);
begin

  Self.Write({' '+}IntToStr(piValue));
end;


procedure TEasyLog.WriteDate(pdtValue : TDateTime);
begin

  Self.Write({' '+}DateToStr(pdtValue));
end;


procedure TEasyLog.WriteError(psCode, psMsg : String);
begin

  WriteTimeStamp;
  Self.Write(psCode);
  Self.Writeln(psMsg);
end;


procedure TEasyLog.WriteBool(pblValue : Boolean);
begin

  if pblValue then
    Self.Write(' True')
  else
    Self.Write(' False');
end;


procedure TEasyLog.WriteLN(psLine : String);
begin

  if not IsLocked then begin

    msLine:=msLine+psLine;
    {if mblCrypted then
      moList.Add(WeakCrypt(msLine,msKey))
    else}
      moList.Add(msLine);
  end;
  msLine:='';
  mblSaved:=False;
end;


procedure TEasyLog.WriteReal(prValue: Real);
begin

  Self.Write({' '+}FloatToStr(prValue));
end;


procedure TEasyLog.WriteTimeStamp(lsMask: String);
begin

  Self.Write(FormatDateTime(lsMask,Now));
end;


function TEasyLog.IsEmpty: Boolean;
begin

  Result:=moList.Count=0;
end;


function TEasyLog.IsNewLine: Boolean;
begin

  Result:=tstr.IsEmpty(msLine);
end;


constructor TEasyLog.Load(psLogName : String; pblCrypted: Boolean; psKey: String);
begin

  moList:=TStringList.Create;
  msLogFolder:=ExtractFilePath(psLogName);
  addSeparator(msLogFolder);
  msLogName:=ExtractFileName(psLogName);
  mblCrypted:=pblCrypted;
  mblSaved:=True;
  if tstr.IsEmpty(psKey) then
    msKey:=csDefaultKey
  else
    msKey:=psKey;
  
  if FileExists(msLogFolder+msLogName) then
    moList.LoadFromFile(msLogFolder+msLogName);
end;


procedure TEasyLog.Reset;
begin

  msLine:='';
  mblSaved:=False; //???
end;


procedure TEasyLog.Lock(pblLockState : Boolean = True);
begin

  if IsLocked then begin

     //***** Залочен
     if not pblLockState then
       mblLocked:=False;

  end else begin

    //***** Разлочен
     if pblLockState then
       mblLocked:=True;
  end;
end;


function TEasyLog.IsLocked : Boolean;
begin

  Result:=mblLocked;
end;


end.
