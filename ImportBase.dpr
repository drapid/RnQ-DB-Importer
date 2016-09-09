program ImportBase;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ImpForm},
  SrcAndrq in 'SrcAndrq.pas',
  RnQ2Base in 'RnQ2Base.pas',
  RnQ2sql in 'RnQ2sql.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Import user base to R&Q2';
  Application.CreateForm(TImpForm, ImpForm);
  Application.Run;
end.
