unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls
  ;

type
  TImpForm = class(TForm)
    SrcPageCntrl: TPageControl;
    andrqSht: TTabSheet;
    RnQDirEdt: TLabeledEdit;
    RnQDirBtn: TButton;
    L1: TLabel;
    LogText: TMemo;
    Label2: TLabel;
    Button1: TButton;
    InfSht: TTabSheet;
    InfDirLEdit: TLabeledEdit;
    InfDirBtn: TButton;
    UIDLEdit: TLabeledEdit;
    ImpExpGrp: TRadioGroup;
    procedure RnQDirBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InfDirBtnClick(Sender: TObject);
    procedure ImpExpGrpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImpForm: TImpForm;

implementation
 uses
   srcAndrq,
   Infium,
//   RnQDialogs, RnQLangs, RQglobal,
//   DISQLite3Api,
  ASGSQLite3Api,
//   SQLite3,
   RnQ2Dlg,
   RnQ2Base;

{$R *.dfm}

//var

procedure TImpForm.Button1Click(Sender: TObject);
var
  isOk : Boolean;
  DBName : AnsiString;
  HDLL : THandle;
begin
  LogText.Clear;
  TButton(Sender).Enabled := False;
  SrcPageCntrl.Enabled := False;
  TASQLite3DB_LoadLibs('sqlite3.dll', HDLL);
  if HDLL = 0 then
    begin
      LogText.Lines.Add('Can''t load dll');
      TButton(Sender).Enabled := True;
      SrcPageCntrl.Enabled := True;
      Exit;
    end;
  DBName := 'history.db3';
  try
    if SQLite3_Open(PAnsiChar(DBName), MineDB) <> 0 then
//    if SQLite3_Open(PAnsiChar(DBName), @MineDB) <> 0 then
     begin
  //		raise ESqliteException.CreateFmt(
  //			'Failed to open database "%s"', [FileName]);
      MineDB := NIL;
      Exit;
     end;
{    mineDB := TDISQLite3Database.Create(self);
    mineDB.DatabaseName := 'history.db3';
    mineDB.CreateDatabase;
    mineDB.CacheSize := 100000;
  //  RnQDB.CreateDatabase;
    mineDB.Open;}

    ExecSQL(MineDB, 'pragma synchronous = off');
    ExecSQL(MineDB, 'pragma temp_store = memory');
    ExecSQL(MineDB, 'PRAGMA journal_mode = MEMORY');
    ExecSQL(MineDB, 'PRAGMA locking_mode = EXCLUSIVE');

    isOk := False;
    if initRnQdb then
     case SrcPageCntrl.ActivePageIndex of
      0: begin
           isOk := ImportFromAndrq( RnQDirEdt.Text, LogText);
         end;
      1: begin
           isOk := ImportFromInfium( InfDirLEdit.Text, LogText, UIDLEdit.Text);
         end;
     end;
//    mineDB.Commit;
//    mineDB.Close;

    ExecSQL(MineDB, 'COMMIT');
    SQLite3_Close(MineDB);

    if not isOk then
     DeleteFileA(PAnsiChar(DBName));
//    FreeAndNil(mineDB);
  finally
   SrcPageCntrl.Enabled := True;
   TButton(Sender).Enabled := True;
  end;
end;

procedure TImpForm.FormCreate(Sender: TObject);
begin
  myPath := ExtractFilePath(paramStr(0));
//  loadLanguage;
  RnQDirEdt.Text := myPath;
end;

procedure TImpForm.ImpExpGrpClick(Sender: TObject);
begin
  if ImpExpGrp.ItemIndex = 0 then
    L1.Caption := 'Select source'
   else
    L1.Caption := 'Select destination';
end;

procedure TImpForm.InfDirBtnClick(Sender: TObject);
var
  DirName : String;
begin
  if OpenDirDialog(Self.Handle, 'Select directory with your profile', DirName) then
   InfDirLEdit.Text := DirName;
end;

procedure TImpForm.RnQDirBtnClick(Sender: TObject);
var
  DirName : String;
begin
  DirName := RnQDirEdt.Text;
  if OpenDirDialog(Self.Handle, 'Select directory with your profile', DirName) then
   RnQDirEdt.Text := DirName;
end;

end.
