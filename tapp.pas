unit tapp;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms
  , tstr
  ;

function getAppFolder : String;

implementation

var msApplicationFolder : String;


function getAppFolder: String;
begin

  Result:=msApplicationFolder;
end;

begin

  msApplicationFolder:=addSeparator(ExtractFileDir(Application.Exename)+DirectorySeparator);
end.

