program Stxprn;

uses
  Forms,
  Stxprn1 in 'STXPRN1.PAS' {StxMain},
  Prting in 'PRTING.PAS' {AbortPrn},
  AboutBox in 'AboutBox.pas' {AboutStx},
//  PLPREVFRM in '..\..\..\..\..\PROGRAM FILES\BORLAND\DELPHI6\PROJECTS\BPL\PLPREVFRM.pas' {plPrevForm},
  Preview in 'Preview.pas' {plPrevForm1};

{$R *.RES}

begin
  Application.CreateForm(TStxMain, StxMain);
  Application.CreateForm(TAbortPrn, AbortPrn);
  Application.CreateForm(TAboutStx, AboutStx);
//  Application.CreateForm(TplPrevForm1, plPrevForm1);
  Application.Run;
end.
