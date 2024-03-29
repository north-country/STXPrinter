unit Stxprn1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Printers, Prting, OleCtrls,
  IniFiles, Menus, AboutBox;

type PrintContext = record
  PrintPos: integer;
  Hmargin: integer;
  AllLines: integer;
  assignY: integer;
  PageNum: integer;
  LineStart: boolean;
  LeftPage: boolean;
end ;

type
  TStxMain = class(TForm)
    StartPrint: TButton;
    FNameBox: TEdit;
    Label5: TLabel;
    CancelButton: TButton;
    RefButton: TButton;
    Label6: TLabel;
    Label7: TLabel;
    WordsBox: TEdit;
    LinesBox: TEdit;
    HukuroBox: TCheckBox;
    OpenDialog1: TOpenDialog;
    Label8: TLabel;
    FontSizeBox: TEdit;
    Button3: TButton;
    PrintDialog1: TPrintDialog;
    MinSelDlg: TFontDialog;
    GroupBox1: TGroupBox;
    GothicSel: TButton;
    AlphaSel: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MinDisp: TLabel;
    GotDisp: TLabel;
    AlphaDisp: TLabel;
    GotSelDlg: TFontDialog;
    AlphaSelDlg: TFontDialog;
    LineNoPrint: TCheckBox;
    SettingDisp: TComboBox;
    SaveSettings: TButton;
    TabBox: TEdit;
    Label9: TLabel;
    IsLandScape: TCheckBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Print1: TMenuItem;
    a1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure StartPrintClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure RefButtonClick(Sender: TObject);
    procedure Init(Sender: TObject);
    procedure EnterKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button3Click(Sender: TObject);
    procedure GothicSelClick(Sender: TObject);
    procedure AlphaSelClick(Sender: TObject);
    procedure SaveSettingsClick(Sender: TObject);
    procedure SettingDispSelect(Sender: TObject);
    procedure About1Click(Sender: TObject);

  private
    { Private declarations }
  public
    procedure SetAbort;
    { Public declarations }
    procedure doSaveSettings(Key: String);
    procedure ReadSettings(Key: String);
    function NewLine(Current: PrintContext; Lmargin: integer; MyPrinter: TPrinter): PrintContext;
    procedure PutLineNo(PC: PrintContext; Lmargin: integer; LineMid: integer;
                             Umargin: integer; MyPrinter: TPrinter);
    procedure doPrint(MyPrinter: TPrinter);

  end;

var
  StxMain: TStxMain;
  InputFile: Text;
  Ita, UnderL, ItaUnderL, Norm: TFontStyles;
  BaseLine: Real;
  PrintingFlag: Boolean;
  FontSize, ULFont: integer;
  StdFont, GotFont, AlphaFont: String;
  InitSet: TIniFile;
  mm_Width, mm_Height: integer;

implementation

{$R *.DFM}


  procedure SetFont(FontStyle: Byte; MyPrinter: TPrinter);
  begin
    case (FontStyle and $07) of
      $00: begin    { Normal }
         MyPrinter.Canvas.Font.Name := StdFont;
         MyPrinter.Canvas.Font.Style := [];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $01: begin     { Gothic }
         MyPrinter.Canvas.Font.Name := GotFont;
         MyPrinter.Canvas.Font.Style := [fsBold];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $02: begin      { Italic }
         MyPrinter.Canvas.Font.Name := StdFont;
         MyPrinter.Canvas.Font.Style := [fsItalic];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $03: begin       { Italic & Gothic }
         MyPrinter.Canvas.Font.Name := GotFont;
         MyPrinter.Canvas.Font.Style := [fsItalic, fsBold];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $04: begin        { UnderLine }
         MyPrinter.Canvas.Font.Name := StdFont;
         MyPrinter.Canvas.Font.Style := [fsUnderline];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $05: begin        { Gothic & UnderLine }
         MyPrinter.Canvas.Font.Name := GotFont;
         MyPrinter.Canvas.Font.Style := [fsUnderline];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $06: begin        { Italic & UnderLine }
         MyPrinter.Canvas.Font.Name := StdFont;
         MyPrinter.Canvas.Font.Style := [fsItalic, fsUnderline];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
      $07: begin        { Gothic, Italic, UnderLine }
         MyPrinter.Canvas.Font.Name := GotFont;
         MyPrinter.Canvas.Font.Style := [fsItalic, fsUnderline];
         MyPrinter.Canvas.Font.Size := FontSize;
         BaseLine := 0;
         ULFont := 1;
         end;
    end;
    case (FontStyle and $18) of
      $10: begin  { Lower }
         MyPrinter.Canvas.Font.Size := Trunc(FontSize / 2 + 0.5);
         BaseLine := MyPrinter.Canvas.TextHeight(' ') * 0.5;  // FontSize / 2;
         ULFont := 2;
         end;
      $08: begin { Upper }
         MyPrinter.Canvas.Font.Size := Trunc(FontSize / 2 + 0.5);
         BaseLine := 0;
         ULFont := 2;
         end;
    end;
  end;


procedure TStxMain.SetAbort;
begin
   PrintingFlag := False;
end;

procedure TStxMain.PutLineNo(PC: PrintContext; Lmargin: integer;
                             LineMid: integer; Umargin: integer; MyPrinter: TPrinter);
var
   CurFont: String;
   CurCharSet: TFontCharSet;
   CurStyle: TFontStyles;
   WidthChars: String;
begin
        CurFont := MyPrinter.Canvas.Font.Name;
        CurCharSet := MyPrinter.Canvas.Font.Charset;
        MyPrinter.Canvas.Font.Name := AlphaFont;
        MyPrinter.Canvas.Font.Charset := ANSI_CHARSET;
        CurStyle := MyPrinter.Canvas.Font.Style;
        MyPrinter.Canvas.Font.Style := Norm;
        WidthChars := IntToStr(PC.AllLines) + ':  ';
        MyPrinter.Canvas.TextOut(Lmargin + PC.Hmargin - MyPrinter.Canvas.TextWidth(WidthChars),
                             Trunc(PC.assignY * LineMid + Umargin + BaseLine),
                             WidthChars);
        MyPrinter.Canvas.Font.Name := CurFont;
        MyPrinter.Canvas.Font.Charset:= CurCharSet;
        MyPrinter.Canvas.Font.Style := CurStyle;

end;

procedure PrintPageNum(PageNum: integer; MyPrinter: TPrinter);
var
   PageChr: String;
   CurFont: String;
  CurStyle: TFontStyles;
  CurCharSet: TFontCharset;
  CurSize: Integer;

begin
   CurFont := MyPrinter.Canvas.Font.Name;
   CurCharSet := MyPrinter.Canvas.Font.Charset;
   MyPrinter.Canvas.Font.Name := AlphaFont;
   MyPrinter.Canvas.Font.Charset := ANSI_CHARSET;
   CurStyle := MyPrinter.Canvas.Font.Style;
   CurSize := MyPrinter.Canvas.Font.Size;
   MyPrinter.Canvas.Font.Size := 10;
   MyPrinter.Canvas.Font.Style := Norm;
   PageChr := '- ' + IntToStr(PageNum)+ ' -';
   // ÊuÍeLg[
   MyPrinter.Canvas.TextOut(((MyPrinter.PageWidth - MyPrinter.Canvas.TextWidth(PageChr)) div 2),
                          Trunc((mm_Height - 10) / mm_Height * MyPrinter.PageHeight),
                                    PageChr);
   MyPrinter.Canvas.Font.Name := CurFont;
   MyPrinter.Canvas.Font.Charset:= CurCharSet;
   MyPrinter.Canvas.Font.Style := CurStyle;
   MyPrinter.Canvas.font.Size := CurSize;
end;


function TStxMain.NewLine(Current: PrintContext; Lmargin: integer; MyPrinter: TPrinter): PrintContext;
begin
    NewLine.PrintPos := 0;
    NewLine.assignY := Current.assignY + 1;
    NewLine.AllLines := Current.AllLines + 1;
    NewLine.LineStart := true;
    NewLine.PageNum := Current.PageNum;
    NewLine.Hmargin := Current.Hmargin;
    NewLine.LeftPage := Current.LeftPage;
    if Current.assignY + 1 >= StrToInt(LinesBox.Text) then begin
         NewLine.assignY := 0;
         if Current.LeftPage and HukuroBox.Checked then begin
             NewLine.Hmargin := (MyPrinter.PageWidth - Lmargin) div 2;
             NewLine.LeftPage := not Current.LeftPage;
         end
         else begin
           PrintPageNum(Current.PageNum, MyPrinter);
           NewLine.PageNum := Current.PageNum + 1;
           MyPrinter.NewPage;
           NewLine.Hmargin := 0;
           NewLine.LeftPage := not Current.LeftPage;
         end;
    end;

end;

procedure TStxMain.StartPrintClick(Sender: TObject);
begin
  if PrintDialog1.Execute then begin
    doPrint(Printer);
  end;
end;

procedure TStxMain.doPrint(MyPrinter: TPrinter);
var
  i, j: integer;
  FontStyle : Byte;

  InChar1, InChar2: AnsiChar;
  DBytes: array[1..2] of AnsiChar;
//  DKinsoku: array [0..20] of char;
//  SKinsoku: array [0..6] of char;
  SByte: array[1..1] of AnsiChar;
  Lmargin, LineMid, Umargin: integer;
  // LeftPage, LineStart: Boolean;
  CurFont: String;
  CurStyle: TFontStyles;
  CurCharSet: TFontCharset;
  TabWidth: integer;
  LineWidth, DLineWidth: integer;
  WidthChars, TabChars: String;
  PC: PrintContext;
  NextPos: integer;
  BaseLineShift: Real; // 5 to 12 % => 8.5%?

begin
    // Printer Initialize..
    if IsLandScape.Checked then MyPrinter.Orientation := poLandScape
    else MyPrinter.Orientation := poPortrait;
    MyPrinter.BeginDoc;
    MyPrinter.Canvas.Font.Name := StdFont;
    FontSize := StrToInt(FontSizeBox.Text);
    MyPrinter.Canvas.Font.Size := FontSize;
    MyPrinter.Canvas.Font.Style := Norm;

    mm_Width := GetDeviceCaps(MyPrinter.Handle, HORZSIZE);
    mm_height := GetDeviceCaps(MyPrinter.Handle, VERTSIZE);

    PrintingFlag := True;
    PC.assignY := 0;
    BaseLine := 0;
    FontStyle := $0;
    PC.PageNum := 1;
    PC.LeftPage := True;
    ULFont := 1;
    PC.Hmargin := 0;
    PC.AllLines := 1;
//    StrCopy(DKinsoku, 'BCjvhpxzfh');
//    StrCopy(SKinsoku, '.,;)}]');
(*  Margin set *)
    LineMid := Trunc(((mm_Height - 40) / mm_Height * MyPrinter.PageHeight) / StrToInt(LinesBox.Text));
    Umargin := Trunc(20 / mm_Height * MyPrinter.PageHeight);
       // ê2cmCãÉ}[WðÇÁ
    PC.PrintPos := 0;
    PC.LineStart := true;
    WidthChars := '';
    for i:= 1 to StrToInt(WordsBox.Text) do WidthChars := WidthChars + ' ';

    LineWidth := MyPrinter.Canvas.TextWidth(WidthChars) ;
    LineWidth := LineWidth div 2;
    DLineWidth := LineWidth - (MyPrinter.Canvas.TextWidth(' ') div 2);
    if HukuroBox.Checked = True then
       Lmargin := Trunc((MyPrinter.PageWidth - LineWidth * 2)/3)
    else
       Lmargin := (MyPrinter.PageWidth-LineWidth) div 2;
    if LMargin < 0 then begin
       Application.MessageBox('Too Much Char', 'StxPrinter', MB_OK + MB_ICONSTOP);
       MyPrinter.Abort;
       exit;
    end;
    BaseLineShift := MyPrinter.Canvas.TextHeight(' ') * 0.05; // 5.0%
{ Start Printing }
    AbortPrn.Show;
    TabChars := '';
    for i:= 1 to StrToInt(TabBox.Text) do TabChars := TabChars + ' ';
    TabWidth := MyPrinter.Canvas.TextWidth(TabChars) div 2;

    AssignFile(InputFile, FNameBox.Text);
    Reset(InputFile);
    while not EOF(InputFile) and AbortPrn.PrintingFlag do begin
      Read(InputFile, InChar1);
      if PC.LineStart and LineNoPrint.Checked then begin
        PutLineNo(PC, Lmargin, LineMid, Umargin, MyPrinter);
        PC.LineStart := false;
      end;
      case Byte(InChar1) of
         $81..$9F, $E0..$FC: begin   { 2bytes char }
            DBytes[1] := InChar1;
            Read(InputFile, InChar2);
            DBytes[2] := InChar2;
            if PC.PrintPos >= DLineWidth then begin
               if AnsiPos(DBytes, 'BCjvhpxzfh')=0 then  begin
                  PC := NewLine(PC, Lmargin, MyPrinter);
//                  if LineNoPrint.Checked then PutLineNo(PC, Lmargin, LineMid, Umargin);
               end;
            end;
            NextPos := PC.PrintPos + MyPrinter.Canvas.TextWidth(DBytes);
            if NextPos >= DLineWidth then begin
              if AnsiPos(Dbytes, 'iougywqs')<> 0 then begin
                 PC := NewLine(PC, Lmargin, MyPrinter);
//                 if LineNoPrint.Checked then PutLineNo(PC, Lmargin, LineMid, Umargin, MyPrinter);
              end;
            end;
            MyPrinter.Canvas.TextOut(PC.PrintPos + Lmargin + PC.Hmargin,
                                 Trunc(PC.assignY * LineMid + Umargin + BaseLine),
                                 DBytes);
            PC.PrintPos := PC.PrintPos + MyPrinter.Canvas.TextWidth(DBytes);
            end;
         $02:
            begin                     { Bold type == Gothic and Bold }
            FontStyle := (FontStyle and $FE) or ((FontStyle and $01) xor $01);
            SetFont(FontStyle, MyPrinter);
            end;
         $13:                         { Italic }
            begin
            FontStyle := (FontStyle and $FD) or ((FontStyle and $02) xor $02);
            SetFont(FontStyle, MyPrinter);
            end;
         $10:                         { UnderLine }
            begin
            FontStyle := (FontStyle and $FB) or ((FontStyle and $04) xor $04);
            SetFont(FontStyle, MyPrinter);
            end;
         $15:                         { Upper }
            begin
            FontStyle := (FontStyle and $F7) or ((FontStyle and $08) xor $08);
            SetFont(FontStyle, MyPrinter);
            end;
         $04:                          { Lower }
            begin
            FontStyle := (FontStyle and $EF) or ((FontStyle and $10) xor $10);
            SetFont(FontStyle, MyPrinter);
            end;
         $0d:
            begin
              PC := NewLine(PC, Lmargin, MyPrinter);
            end;
         $0a:             {LF}
            begin
            end;
         $09:
            begin
              j := 1;
              while PC.PrintPos >= j*TabWidth do begin
                 j := j+1;
              end;
//              if PrintPos = j*TabWidth then j := j+1;
              PC.PrintPos := j*TabWidth;
            end;
         $0c:
            begin
//              PC := NewLine(PC, Lmargin, MyPrinter);
              PC.assignY := 0;
              PC.LineStart := true;
              PC.PrintPos := 0;
              if PC.LeftPage and HukuroBox.Checked then begin
                PC.Hmargin := (MyPrinter.PageWidth - Lmargin) div 2;
                PC.LeftPage := not PC.LeftPage;
                end
              else begin
                PrintPageNum(PC.PageNum, MyPrinter);
                PC.PageNum := PC.PageNum + 1;
                MyPrinter.NewPage;
                PC.Hmargin := 0;
                PC.LeftPage := not PC.LeftPage;
              end;
            end;
         else  begin
            SByte[1] := InChar1;
            if PC.PrintPos >= LineWidth then begin
              if AnsiPos(SByte, '.,;)}]')=0 then begin
                PC := NewLine(PC, Lmargin, MyPrinter);
              end;
            end;
            CurFont := MyPrinter.Canvas.Font.Name;
            CurCharSet := MyPrinter.Canvas.Font.Charset;
            MyPrinter.Canvas.Font.Name := AlphaFont;
            MyPrinter.Canvas.Font.Charset := ANSI_CHARSET;
            CurStyle := MyPrinter.Canvas.Font.Style;
            NextPos := PC.PrintPos + MyPrinter.Canvas.TextWidth(SByte);
            if NextPos >= LineWidth then begin
              if AnsiPos(Sbyte, '([{')<>0 then
                 PC := NewLine(PC, Lmargin, MyPrinter);
            end;
            MyPrinter.Canvas.TextOut(PC.PrintPos + Lmargin + PC.Hmargin,
                                 trunc(PC.assignY * LineMid + Umargin + BaseLine - BaseLineShift),
                                 SByte);
            PC.PrintPos := PC.PrintPos + MyPrinter.Canvas.TextWidth(SByte);
            MyPrinter.Canvas.Font.Name := CurFont;
            MyPrinter.Canvas.Font.Charset:= CurCharSet;
          end;
       end;
    end; { while }
    if AbortPrn.PrintingFlag then begin
      PrintPageNum(PC.PageNum, MyPrinter);
      AbortPrn.Close;
      MyPrinter.EndDoc;
      Application.MessageBox('óüI¹', 'Stx Printer', MB_OK);
      end
    else begin
       AbortPrn.Close;
 {    Printer.Abort;  }
       MyPrinter.EndDoc;
    end;
    CloseFile(InputFile);
end;


procedure TStxMain.CancelButtonClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TStxMain.RefButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
     FNameBox.Text := OpenDialog1.FileName;
  end;
end;

procedure TStxMain.doSaveSettings(Key: String);
begin
   InitSet.WriteString(Key, 'StdFont', StdFont);
   InitSet.WriteString(Key, 'GotFont', GotFont);
   InitSet.WriteString(Key, 'AlphaFont', AlphaFont);
   InitSet.WriteString(Key, 'Width', WordsBox.Text);
   InitSet.WriteString(Key, 'Length', LinesBox.Text);
   InitSet.WriteString(Key, 'TabLength', TabBox.Text);
   InitSet.WriteBool(Key, 'Hukuro', HukuroBox.Checked);
   InitSet.WriteBool(Key, 'LinePrint', LineNoPrint.Checked);
   InitSet.WriteBool(Key, 'LandScape', IsLandScape.Checked);
   InitSet.ReadSections(SettingDisp.Items);
end;

procedure TStxMain.ReadSettings(Key: String);
begin
   StdFont := InitSet.ReadString(Key, 'StdFont', StdFont);
   MinDisp.Caption:= StdFont;
   GotFont := InitSet.ReadString(Key, 'GotFont', GotFont);
   GotDisp.Caption:=GotFont;
   AlphaFont := InitSet.ReadString(Key, 'AlphaFont', AlphaFont);
   AlphaDisp.Caption := AlphaFont;
   WordsBox.Text := InitSet.ReadString(Key, 'Width', WordsBox.Text);
   LinesBox.Text := InitSet.ReadString(Key, 'Length', LinesBox.Text);
   TabBox.Text :=  InitSet.ReadString(Key, 'TabLength', TabBox.Text);
   HukuroBox.Checked :=  InitSet.ReadBool(Key, 'Hukuro', HukuroBox.Checked);
   LineNoPrint.Checked := InitSet.ReadBool(Key, 'LinePrint', LineNoPrint.Checked);
   IsLandScape.Checked := InitSet.ReadBool(Key, 'LandScape', IsLandScape.Checked);

end;

procedure TStxMain.Init(Sender: TObject);
var
   i: integer;
   KeyString: String;

begin
   StdFont := 'lr ¾©';
   MinDisp.Caption:= StdFont;
   GotFont := 'lr SVbN';
   GotDisp.Caption:=GotFont;

   AlphaFont := 'Times New Roman';
   AlphaDisp.Caption := AlphaFont;
   InitSet := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\stx.ini');

   InitSet.ReadSections(SettingDisp.Items);
   if InitSet.ReadString('default', 'StdFont', '') = '' then
      doSaveSettings('default')
   else
      ReadSettings('default');

//  Ignore Environment variable
{   width := GetEnvironmentVariable('StxWidth');
   height := GetEnvironmentVariable('StxHeight');
   if width <> '' then if StrToInt(width) <> 0 then wordsbox.Text := width;
   if height <> '' then if StrToInt(height) <> 0 then linesbox.Text := height;
}


   if paramCount >=1 then begin
      FNameBox.text := paramStr(1);
      if paramCount >= 4 then begin
         KeyString := paramStr(4) ;
         if InitSet.ReadString(KeyString, 'StdFont', '') <> '' then begin
             ReadSettings(KeyString);
             SettingDisp.Text  := KeyString;
         end;
      end;
      if paramCount >= 2 then begin
         if StrToInt(paramStr(2)) <> 0 then wordsbox.Text := paramStr(2);
         if paramCount >= 3 then begin
           if StrToInt(paramStr(3)) <> 0 then linesbox.Text := paramStr(3);
         end;
      end;
   end;
end;

procedure TStxMain.EnterKey(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_Return then
     StartPrintClick(Sender);

end;

procedure TStxMain.Button3Click(Sender: TObject);
begin
   MinSelDlg.Font.Name := StdFont;
   MinSelDlg.Font.Size := StrToInt(FontSizeBox.Text);

   if MinSelDlg.Execute then begin
     if MinSelDlg.Font.Charset = SHIFTJIS_CHARSET then begin
       StdFont := MinSelDlg.Font.Name;
       FontSizeBox.Text := IntToStr(MinSelDlg.Font.Size);
       MinDisp.Caption:= StdFont;
     end;
   end;
end;


procedure TStxMain.AlphaSelClick(Sender: TObject);
begin
   AlphaSelDlg.Font.Name := AlphaFont;
   AlphaSelDlg.Font.Size := StrToInt(FontSizeBox.Text);

   if AlphaSelDlg.Execute then begin
     if AlphaSelDlg.Font.Charset = ANSI_CHARSET then begin
       AlphaFont := AlphaSelDlg.Font.Name;
       FontSizeBox.Text := IntToStr(AlphaSelDlg.Font.Size);
       AlphaDisp.Caption:= AlphaFont;
     end;
   end;

end;
procedure TStxMain.GothicSelClick(Sender: TObject);
begin
   GotSelDlg.Font.Name := GotFont;
   GotSelDlg.Font.Size := StrToInt(FontSizeBox.Text);

   if GotSelDlg.Execute then begin
     if GotSelDlg.Font.Charset = SHIFTJIS_CHARSET then begin
       GotFont := GotSelDlg.Font.Name;
       FontSizeBox.Text := IntToStr(GotSelDlg.Font.Size);
       GotDisp.Caption:= GotFont;
     end;
   end;

end;

procedure TStxMain.SaveSettingsClick(Sender: TObject);
begin
   SettingDisp.SetFocus;
   doSaveSettings(SettingDisp.SelText);
end;

procedure TStxMain.SettingDispSelect(Sender: TObject);
begin
   ReadSettings(SettingDisp.Text);
end;

procedure TStxMain.About1Click(Sender: TObject);
begin
   AboutStx.Show;
end;

end.
