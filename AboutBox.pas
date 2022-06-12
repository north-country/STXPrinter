unit AboutBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TAboutStx = class(TForm)
    AboutClose: TButton;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    procedure AboutCloseClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  AboutStx: TAboutStx;

implementation

{$R *.dfm}

procedure TAboutStx.AboutCloseClick(Sender: TObject);
begin
    self.Close;
end;

end.
