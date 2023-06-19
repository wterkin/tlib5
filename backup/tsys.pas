unit tsys;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

function getAppFolder : String;

implementation

var msApplicationFolder : String;

begin

  msApplicationFolder:=addSeparator(ExtractFileDir(Application.Exename));


end.

