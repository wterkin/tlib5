unit tprogress;


interface

uses ComCtrls, forms;

type

     TProgressDirection = (pdForward, pdBackward);

     { TEasyProgressBar }
     TEasyProgressBar = class(TObject)
       private

         miCoefficient : Integer;
         moProgressBar : TProgressBar;
         mpdDirection  : TProgressDirection;
         procedure reCalc(plTotalCycles : LongInt);
       public

         constructor Create(poProgressBar : TProgressBar = Nil);
         procedure setup(plTotalCycles : Longint; piStepSize : Integer = 1);
         procedure step(plCurrentCycle : Longint);
         procedure Reset();
         procedure Finish();
         procedure thereAndBackAgain();
		 end;

implementation


{ TEasyProgressBar }

procedure TEasyProgressBar.reCalc(plTotalCycles: LongInt);
begin

  miCoefficient := plTotalCycles div 100;
  if miCoefficient = 0 then
  begin

    miCoefficient := 1;
	end;
end;

constructor TEasyProgressBar.Create(poProgressBar: TProgressBar);
begin

	miCoefficient := -1;
  mpdDirection := pdForward;
  moProgressBar := poProgressBar;
  if moProgressBar <> Nil then
  begin

    moProgressBar.Position:=0;
    moProgressBar.Min:=0;

	end
	else begin

    Free;
  end;
end;

procedure TEasyProgressBar.setup(plTotalCycles: Longint; piStepSize: Integer);
begin

  recalc(plTotalCycles);
  moProgressBar.Step:=piStepSize;
  moProgressBar.Max:=plTotalCycles div miCoefficient;
  //moProgressBar.Step:=1;
end;

procedure TEasyProgressBar.step(plCurrentCycle: Longint);
begin

  if (plCurrentCycle > 0) and (plCurrentCycle mod miCoefficient=0) then
  begin

		moProgressBar.StepIt;
  end;
end;

procedure TEasyProgressBar.Reset;
begin

  moProgressBar.Position := 0;
end;

procedure TEasyProgressBar.Finish;
begin

  moProgressBar.Position := moProgressBar.Max;
end;

procedure TEasyProgressBar.thereAndBackAgain;
begin

  if mpdDirection = pdForward then begin

    if moProgressBar.Position<moProgressBar.Max then begin

      moProgressBar.StepIt;
    end else begin

      mpdDirection:= pdBackward;
      thereAndBackAgain();
    end;
  end else begin

    if moProgressBar.Position>moProgressBar.Min then begin

      moProgressBar.StepBy(-1);
    end else begin

      mpdDirection := pdForward;
      thereAndBackAgain();
    end;
  end;
  Application.ProcessMessages;
end;

end.
