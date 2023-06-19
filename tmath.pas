unit tmath;

interface


function RoundEx(pdValue : Double) : Double;

function RoundEx2(X: Double; Y:Integer): Double;


implementation


function roundEx(pdValue : Double) : Double;
var ldScaledFractPart,
    ldValue1         : Double;
    liValue2         : integer;
begin

  ldScaledFractPart:=Frac(pdValue)*100;
  ldValue1:=Frac(ldScaledFractPart);
  ldScaledFractPart:=Int(ldScaledFractPart);
  liValue2:=Round(ldValue1*10);
  if liValue2>=5 then begin

    ldScaledFractPart:=ldScaledFractPart+1;
  end;
  if liValue2<=-5 then begin

    ldScaledFractPart := ldScaledFractPart - 1;
  end;
  RoundEx := Int(pdValue) + ldScaledFractPart/100;
end;


function RoundEx2(X: Double; Y:Integer): Double;
var ScaledFractPart,
    T1: Double;
    T2:integer;
    I:Double;
begin
    I:=exp(Y*ln(10));
    ScaledFractPart := Frac(X) * ROUND(I);
    T1 := Frac(ScaledFractPart);
    ScaledFractPart := Int(ScaledFractPart);
    T2:=round(T1*10);
    if  ( T2 >= 5 ) then
    begin
      ScaledFractPart := ScaledFractPart + 1;
    end;
    if (T2 <= -5) then
    begin
      ScaledFractPart := ScaledFractPart - 1;
    end;
    RoundEx2 := Int(X) + ScaledFractPart / ROUND(I);
end;

end.