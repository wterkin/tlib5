unit tmsg;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,  Dialogs, Controls;

{** @abstract(Функция выводит на десктоп окно с заданным текстом и иконкой уведомления)
    @param(psTroubleDesc основное сообщение)
    @param(psDetail уточняющее сообщение)
    @return(@true, если сообщение успешно выведено, иначе @false)
    @code(notify('Сообщение','Операция завершилась корректно');)}
procedure notify(psTroubleDesc, psDetail : String);

{** @abstract(Функция выводит на десктоп окно с заданным текстом и двумя кнопками и
              предлагает произвести выбор из двух возможных действий.)
    @param(psTroubleDesc основное сообщение)
    @param(psDetail уточняющее сообщение)
    @return(@true, если была нажата кнопка 'Да', иначе @false)
    @code(askYesNo('Внимание!','Все данные на диске C: будут уничтожены. Продолжить?');)}
function  askYesOrNo(psTroubleDesc : String) : Boolean;

{** @abstract(Функция выводит на десктоп окно с заданным текстом и иконкой ошибки)
    @param(psTroubleDesc основное сообщение)
    @param(psDetail уточняющее сообщение)
    @return(@true, если сообщение успешно выведено, иначе @false)
    @code(fatalError('Ошибка!','Программа аварийно завершена!'))}
procedure fatalError(psErrorDesc, psDetail : String);


implementation

procedure notify(psTroubleDesc, psDetail : String);
begin

  MessageDlg(psTroubleDesc, psDetail, mtInformation, [mbOK],'notice');
end;


function askYesOrNo(psTroubleDesc : String) : Boolean;
begin

  askYesOrNo:=(MessageDlg(psTroubleDesc, mtConfirmation, [mbYes,mbNo], 0) = mrYes);
end;


procedure fatalError(psErrorDesc, psDetail : String);
begin

  MessageDlg(psDetail, psErrorDesc, mtError, [mbOK], 'error');
end;


end.

