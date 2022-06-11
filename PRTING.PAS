unit Prting;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TAbortPrn = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ActivateAbortPrn(Sender: TObject);
  private
    { Private declarations }
  public
    PrintingFlag: Boolean;
    { Public declarations }
  end;

var
  AbortPrn: TAbortPrn;

implementation

{$R *.DFM}

procedure TAbortPrn.Button1Click(Sender: TObject);
begin
  PrintingFlag := False;
end;

procedure TAbortPrn.ActivateAbortPrn(Sender: TObject);
begin
  PrintingFlag := True;
end;

end.
