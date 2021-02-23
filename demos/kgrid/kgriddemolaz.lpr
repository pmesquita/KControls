program kgriddemolaz;

uses
  Interfaces,
  Forms,
  Main in 'main.pas',
  Input in 'input.pas';

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
