program kw_ai_15;

uses
  Forms,
  MUnit in 'MUnit.pas' {MForm},
  MapUnit in 'MapUnit.pas',
  AIUnit in 'AIUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMForm, MForm);
  Application.Run;
end.
