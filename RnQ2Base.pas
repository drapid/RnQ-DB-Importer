unit RnQ2Base;

interface

uses
//  DISQLite3Database,
//  SQLite3,
//  DISQLite3Api,
  ASGSQLite3Api,
  Controls;

  function initRnQdb : Boolean;
//  function UpdateCntField(cntID : Int64; Field :string; val: string) : Boolean; overload;
//  function UpdateCntFieldBlob(cntID : Int64; Field :string; val: string) : Boolean;
//  function UpdateCntField(cntID : Int64; Field :string; val: Integer) : Boolean; overload;
//  function UpdateCntField(cntID : Int64; Field :string; val: TDate) : Boolean; overload;
//  function UpdateCntField(cntID : Int64; Field :string; val: TDateTime) : Boolean; overload;
//  function FindContact(UID : String) : Int64;

type
  TupdField = record
    f : String;
    val1 : String;
    val2 : Int64;
    val3 : TDateTime;
    val4 : AnsiString;
    val_type : Byte;
  end;
  TupdFields = array of TupdField;

//  function UpdateCntFields(cntID : Int64; Fields :TupdFields) : Boolean;

const
  EK_null         = 00;
  EK_msg          = 01;
  EK_url          = 02;
  EK_contacts     = 03;
  EK_file         = 04;
  EK_authReq      = 05;
  EK_AddedYou     = 06;
  EK_oncoming     = 07;
  EK_offgoing     = 08;
  EK_auth         = 09;
  EK_authDenied   = 10;
  EK_statuschange = 11;
  EK_automsgreq   = 12;
  EK_gcard        = 13;
  EK_automsg      = 14;
  EK_typingBeg    = 15;
  EK_typingFin    = 16;
//  EK_statuschangeExt = 17;
  EK_XstatusMsg   = 17;
  EK_Xstatusreq   = 18;
  EK_last         = 18;
type
  Thevent= class
    isSend     : byte;
    IM         : byte;
    flags      : Integer;
    ID         : Integer;
    kind       : integer;
    fpos       : integer;
    expires    : integer;  // tenths of second, negative if permanent
    who        : AnsiString;
    whom       : AnsiString;
    when       : TdateTime;
    cryptMode  : byte;
//    cl         :Tcontactlist;
//    Text       : WideString;
//    Text       : UnicodeString;
    TextUTF    : AnsiString;
    Bin        : RawByteString;
  end;

  procedure beforeInsertHistory;
  procedure AfterInsertHistory;
  function InsertHist(ev :Thevent) : Boolean;

  procedure beforeInsertCList;
  procedure AfterInsertCList;
  function InsertSysCList(CList : Byte; UID_utf8 : RawByteString) : Boolean;

  function logTimestamp:string;
  function ExecSQL(db : Pointer; const sql : String) : Boolean;

var
//  mineDB : TDISQLite3Database;
//  MineDB : TSQLiteDB;
//  MineDB : sqlite3;
  MineDB : TSQLite3DbHandle;
  myPath : String;
  timeformat_log : String;

implementation
  uses
  DateUtils,
    SysUtils, StrUtils,
//    RQGlobal,
//    DISQLite3Api,
    RnQ2sql;

function ExecSQL(db : Pointer; const sql : String) : Boolean;
var
 ss : UTF8String;
 PF: PAnsiChar;
 err : PAnsiChar;
 errMsg : AnsiString;
begin
  ss :=  sql;
// PF := PAnsiChar(AnsiToUtf8(TheStatement))
  PF := PAnsiChar(ss);
  Result := True;
  if SQLite3_Exec(db, PF, NIL, NIL, err) <> SQLITE_OK then
//  if SQLite3_Exec(db, PF, NIL, NIL, @err) <> SQLITE_OK then
   begin
//    msgDlq
     errMsg := StrPas(err);
     sqlite3_free(err);
     Result := False;
   end;
end;



const
  IMTYPE_ICQ = 0;
//  CRLF = #13#10;

{
function UpdateCntFields(cntID : Int64; Fields :TupdFields) : Boolean;
var
  sql, sub : AnsiString;
//  Stmt: TDISQLite3Statement;
//  Stmt: TSQLiteStmt;
  Stmt: sqlite3_stmt;
  I: Integer;
  Tail : PAnsiChar;
begin
//  Sel := format(SQLUpdateContact, [Field, val, cntID]);
   Result := false;
   sub := '';
   if Length(Fields) = 0 then
     Exit;
   for I := 0 to Length(Fields) - 1 do
    begin
      sub := sub +'"' + Fields[i].f + '" = ?,'
    end;
  Delete(sub, length(sub), 1);
  sql := ReplaceStr(SQLUpdateOscarCnt10, '%s', sub);
//  sqlite3_exec_fast(mineDB.Handle, 'BEGIN TRANSACTION');
//  i := SQLite3_Prepare16_v2(MineDB, PWideChar(sql), (Length(sql)+1) * 2, Stmt, Tail);
//  i := SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), (Length(sql)), Stmt, Tail);
  i := SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), (Length(sql)), @Stmt, @Tail);
  if Stmt <> NIL then
  try
//      Stmt := mineDB.Prepare16(sel);
      sql := '';
      try
       for I := 0 to Length(Fields) - 1 do
        begin
//        Stmt.Bind_Str(1, Field);
         case Fields[i].val_type of
           1: //Stmt.bind_Str(i+1, Fields[i].val1);
//              SQLite3_Bind_text16(stmt, i+1, PWideChar(Fields[i].val1), (Length(Fields[i].val1)+1)*2, nil);
              SQLite3_Bind_text(stmt, i+1, PAnsiChar(Fields[i].val1), Length(Fields[i].val1), nil);
           2: //Stmt.bind_Int64(i+1, Fields[i].val2);
              SQLite3_Bind_int64(stmt, i+1, Fields[i].val2);
           3: //Stmt.Bind_Double(i+1, DateTimeToJulianDate( Fields[i].val3));
              sqlite3_bind_Double(stmt, i+1, DateTimeToJulianDate(Fields[i].val3));
           4: //Stmt.bind_Str(i+1, Fields[i].val1);
              SQLite3_Bind_Blob(stmt, i+1, PAnsiChar(Fields[i].val4), Length(Fields[i].val4), nil);
         end;

        end;
//       Stmt.bind_Int64(Length(Fields)+1, cntID);
       SQLite3_Bind_int64(stmt, Length(Fields)+1, cntID);
//       if Stmt.Step = SQLITE_ROW then
       if Sqlite3_Step(stmt) = SQLITE_ROW then
         begin
           Result := True;
         end
      finally
//        FreeAndNil(Stmt);
       SQLite3_Reset(stmt);
      end;
  finally
//    sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
  end;
  SQLite3_Finalize(stmt);
end;
}
var
//   InsHistStmt: TDISQLite3Statement;
//  InsHistStmt: TSQLiteStmt;
//  InsHistStmt: SQLite3_Stmt;
//  InsSysCListStmt : SQLite3_Stmt;
  InsHistStmt: TSQLite3StmtHandle;
  InsSysCListStmt : TSQLite3StmtHandle;

procedure beforeInsertHistory;
var
  sql : UTF8String;
  Tail : PAnsiChar;
begin
//  sqlite3_exec_fast(mineDB.Handle, 'BEGIN TRANSACTION');
  execSQL(mineDB, 'BEGIN TRANSACTION');
  sql := SQLInsertHistory;
//  try
//      InsHistStmt := mineDB.Prepare16(SQLInsertHistory);
//  SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), Length(sql), @InsHistStmt, @Tail);
  SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), Length(sql), InsHistStmt, Tail);
end;
procedure AfterInsertHistory;
begin
//  FreeAndNil(InsHistStmt);
//  sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
  SQLite3_Finalize(InsHistStmt);
  execSQL(mineDB, 'COMMIT TRANSACTION');
end;

function InsertHist(ev :Thevent) : Boolean;
var
  sel, sub : string;
//  msg, inf : String;
//  I: Integer;
begin
//  Sel := format(SQLUpdateContact, [Field, val, cntID]);
   Result := false;
   sub := '';
   sel := '';
      try
//       for I := 0 to Length(Fields) - 1 do
        begin

{         InsHistStmt.Bind_Double(1, DateTimeToJulianDate(ev.when));
//         Stmt.Bind_Double(2, );
         InsHistStmt.Bind_Int(2, ev.isSend);
         InsHistStmt.Bind_Int(3, 0);
         InsHistStmt.Bind_Str(4, ev.who);
         InsHistStmt.Bind_Str(5, ev.whom);
         InsHistStmt.Bind_Int(6, ev.kind);
         InsHistStmt.Bind_Int(7, ev.flags);
         InsHistStmt.Bind_Str(8, ev.Bin);
//         InsHistStmt.Bind_Str(7, ev.Text);
         InsHistStmt.Bind_Str16(9, ev.Text);
}
         sqlite3_bind_Double(InsHistStmt, 1, DateTimeToJulianDate(ev.when));
         SQLite3_Bind_Int(InsHistStmt, 2, ev.isSend);
         SQLite3_Bind_Int(InsHistStmt, 3, ev.im);
         SQLite3_Bind_text(InsHistStmt, 4, PAnsiChar(ev.who), Length(ev.who), nil);
         SQLite3_Bind_text(InsHistStmt, 5, PAnsiChar(ev.whom), Length(ev.whom), nil);
         SQLite3_Bind_Int(InsHistStmt, 6, ev.kind);
         SQLite3_Bind_Int(InsHistStmt, 7, ev.flags);

         SQLite3_Bind_Blob(InsHistStmt, 8, PAnsiChar(ev.Bin), Length(ev.Bin), nil);
//         SQLite3_Bind_text16(InsHistStmt, 9, PWideChar(ev.Text), (Length(ev.Text)+1)*2, nil);
         SQLite3_Bind_text(InsHistStmt, 9, PAnsiChar(ev.TextUTF), Length(ev.TextUTF), nil);

//        Stmt.Bind_Str(1, Field);
//         case Fields[i].val_type of
//           1: Stmt.bind_Str(i+1, Fields[i].val1);
//           2: Stmt.bind_Int64(i+1, Fields[i].val2);
//           3: Stmt.Bind_Str(i+1, DateTimeToStr(Fields[i].val3));
//         end;

        end;
//       Stmt.bind_Int64(Length(Fields)+1, cntID);
//       if InsHistStmt.Step = SQLITE_ROW then
       if Sqlite3_Step(InsHistStmt) = SQLITE_ROW then
         begin
           Result := True;
         end;
//       InsHistStmt.Reset;
       SQLite3_Reset(InsHistStmt);
      finally
//        FreeAndNil(Stmt);
      end;
//  finally
//    sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
//  end;
end;

procedure beforeInsertCList;
var
  sql : UTF8String;
  Tail : PAnsiChar;
begin
  execSQL(mineDB, 'BEGIN TRANSACTION');
  sql := SQLInsertSysCList;
//  SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), Length(sql), @InsSysCListStmt, @Tail);
  SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), Length(sql), InsSysCListStmt, Tail);
end;
procedure AfterInsertCList;
begin
//  FreeAndNil(InsHistStmt);
//  sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
  SQLite3_Finalize(InsSysCListStmt);
  execSQL(mineDB, 'COMMIT TRANSACTION');
end;
function InsertSysCList(CList : Byte; UID_utf8 : RawByteString) : Boolean;
//var
//  sel, sub : string;
//  msg, inf : String;
//  I: Integer;
begin
   Result := false;
//   sub := '';
//   sel := '';
      try
        begin
         SQLite3_Bind_Int(InsSysCListStmt, 1, CList);
         SQLite3_Bind_text(InsSysCListStmt, 2, PAnsiChar(UID_utf8), Length(UID_utf8), nil);
        end;
       if Sqlite3_Step(InsSysCListStmt) = SQLITE_ROW then
         begin
           Result := True;
         end;
       SQLite3_Reset(InsSysCListStmt);
      finally
      end;
end;


(*
function UpdateCntFieldBlob(cntID : Int64; Field :string; val: string) : Boolean;
var
  sel : string;
  Stmt: TDISQLite3Statement;
begin
//  Sel := format(SQLUpdateContact, [Field, val, cntID]);
   Result := false;
  sel := ReplaceStr(SQLUpdateOscarCnt, '%s', Field);
  sqlite3_exec_fast(mineDB.Handle, 'BEGIN TRANSACTION');
  try
      Stmt := mineDB.Prepare16(sel);
      sel := '';
      try
//        Stmt.Bind_Str(1, Field);
        Stmt.bind_Str(1, val);
        Stmt.bind_Int64(2, cntID);
        if Stmt.Step = SQLITE_ROW then
          begin
            Result := True;
          end
      finally
        FreeAndNil(Stmt);
      end;
  finally
    sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
  end;
end;
(*
{function UpdateCntField(cntID : Int64; Field :string; val: TDate) : Boolean;
var
  sel : string;
  Stmt: TDISQLite3Statement;
begin
//  Sel := format('UPDATE UserBase set "%s" = ''%s'' WHERE idx = %s', [Field, DateToStr( val), IntToStr(cntID)]);
   Result := false;
  sel := ReplaceStr(SQLUpdateOscarCnt, '%s', Field);
    begin
      Stmt := mineDB.Prepare16(sel);
      sel := '';
      try
//        Stmt.Bind_Str(1, Field);
        Stmt.Bind_Str(1, DateToStr(val));
        Stmt.bind_Int64(2, cntID);
        if Stmt.Step = SQLITE_ROW then
          begin
            Result := True;
          end
      finally
        FreeAndNil(Stmt);
      end;
    end;
end;
 }
function UpdateCntField(cntID : Int64; Field :string; val: TDateTime) : Boolean;
var
  sel : string;
  Stmt: TDISQLite3Statement;
begin
//  Sel := format('UPDATE UserBase set "%s" = ''%s'' WHERE idx = %s', [Field, DateToStr( val), IntToStr(cntID)]);
   Result := false;
  sel := ReplaceStr(SQLUpdateOscarCnt, '%s', Field);
    begin
      Stmt := mineDB.Prepare16(sel);
      sel := '';
      try
//        Stmt.Bind_Str(1, Field);
        Stmt.Bind_Str(1, DateTimeToStr(val));
        Stmt.bind_Int64(2, cntID);
        if Stmt.Step = SQLITE_ROW then
          begin
            Result := True;
          end
      finally
        FreeAndNil(Stmt);
      end;
    end;
end;

function UpdateCntField(cntID : Int64; Field :string; val: Integer) : Boolean;
var
  sel : string;
  Stmt: TDISQLite3Statement;
begin
//  Sel := format('Update UserBase set "%s" = ''%d'' WHERE idx = %d', [Field, val, cntID]);
  sel := ReplaceStr(SQLUpdateOscarCnt, '%s', Field);
   Result := false;
    begin
      Stmt := mineDB.Prepare16(sel);
      sel := '';
      try
//        Stmt.Bind_Str(1, Field);
        Stmt.Bind_Int(1, val);
        Stmt.bind_Int64(2, cntID);
        if Stmt.Step = SQLITE_ROW then
          begin
            Result := True;
          end
      finally
        FreeAndNil(Stmt);
      end;
    end;
end;
*)
(*
function UpdateCntField(cntID : Int64; Field :string; val: string) : Boolean;
var
  sel : string;
//  Stmt: TDISQLite3Statement;
begin
  Sel := format(SQLUpdateOscarCnt2, [Field, val, cntID]);
   Result := True;
   sqlite3_exec_fast(mineDB.Handle, 'BEGIN TRANSACTION');
   try
    sqlite3_exec_fast(mineDB.Handle, sel);
   finally
     sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
   end;
{//    mineDB.Execute();
//  sel := ReplaceStr(SQLUpdateOscarCnt, '%s', Field);
    begin
      Stmt := mineDB.Prepare(SQLUpdateOscarCnt);
      sel := '';
      try
        Stmt.Bind_Str(1, Field);
        Stmt.bind_Str(2, val);
        Stmt.bind_Int64(3, cntID);
        if Stmt.Step = SQLITE_ROW then
          begin
            Result := True;
          end
      finally
        FreeAndNil(Stmt);
      end;
    end;}
end;
function UpdateCntField(cntID : Int64; Field :string; val: Integer) : Boolean;
var
  sel : string;
begin
  Sel := format(SQLUpdateOscarCnt3, [Field, val, cntID]);
   Result := True;
   sqlite3_exec_fast(mineDB.Handle, 'BEGIN TRANSACTION');
   try
    sqlite3_exec_fast(mineDB.Handle, sel);
   finally
     sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
   end;
end;
function UpdateCntField(cntID : Int64; Field :string; val: TDateTime) : Boolean;
//var
//  sel : string;
begin
  UpdateCntField(cntID, Field, DateTimeToStr(val));
{  Sel := format(SQLUpdateOscarCnt2, [Field, DateTimeToStr(val), cntID]);
   Result := True;
   sqlite3_exec_fast(mineDB.Handle, 'BEGIN TRANSACTION');
   try
    sqlite3_exec_fast(mineDB.Handle, sel);
   finally
     sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
   end;}
end;
*)
{
function FindContact(UID : String) : Int64;
var
//  Stmt: TDISQLite3Statement;
  Stmt: TSQLiteStmt;
  sql : AnsiString;
  Tail : PAnsiChar;
  i : Integer;
begin
//  Result := FCitiesCache.GetItem(ARowID);
//  if not Assigned(Result) then
//   Result := -1;
   UID := ReplaceStr(UID, ' ', '');
//   Stmt := mineDB.Prepare16('SELECT RowID FROM OscarBase WHERE UID = ?;');
   sql := 'SELECT RowID FROM OscarBase WHERE UID = ?;';
   i := SQLite3_Prepare_v2(MineDB, PAnsiChar(sql), (Length(sql)), Stmt, Tail);
   if Stmt <> NIL then
    begin
      try
        Stmt.Bind_Str(1, UID);
        if Stmt.Step = SQLITE_ROW then
          begin
//            Result := IntToStr(ARowID);
            Result := Stmt.Column_Int64(0);
          end
         else // Create new row
          begin
//           FreeAndNil(Stmt);
//           Stmt := mineDB.Prepare16('SELECT Idx, RowID FROM UserBase WHERE UID = ?;');
//            mineDB.StartTransaction(ttExclusive);
            mineDB.Execute(Format(SQLInsertContact, [UID]));
//            mineDB.Commit;

            Result := mineDB.LastInsertRowID;
          end; 

      finally
        FreeAndNil(Stmt);
      end;
    end;
end;
}

function initRnQdb : Boolean;
begin
//  Result := False;
  ExecSQL(mineDB, 'BEGIN TRANSACTION');
{  ExecSQL(MineDB, SQLCreateDBTable);
  ExecSQL(MineDB, SQLCreateOscarDBTable);
  ExecSQL(MineDB, SQLCreateDB2IMTable);
}
  ExecSQL(MineDB, SQLCreateHistTable);

//  ExecSQL(MineDB, 'DROP TABLE CLIST_TYPES;');
  if ExecSQL(MineDB, SQLCreate_CLIST_TYPES) then
    ExecSQL(MineDB, SQLData_CLIST_TYPES);
  ExecSQL(MineDB, SQLCreate_SYS_CLISTS);
  ExecSQL(MineDB, SQLCreateDBTable);
  ExecSQL(MineDB, SQLCreatePrefTable);
  ExecSQL(MineDB, SQLCreateExStsTable);
  ExecSQL(mineDB, 'COMMIT');

  ExecSQL(MineDB, 'ATTACH DATABASE "RnQAvatars.db3" as RAVT;');
  ExecSQL(mineDB, 'BEGIN TRANSACTION');
  ExecSQL(MineDB, SQLCreate_RnQ_AVT);
  ExecSQL(mineDB, 'COMMIT');

{
  mineDB.StartTransaction(ttExclusive);
  mineDB.Execute(SQLCreateDBTable);
  mineDB.Execute(SQLCreateOscarDBTable);
  mineDB.Execute(SQLCreateDB2IMTable);
  mineDB.Execute(SQLCreateHistTable);
  mineDB.Commit;
}
  Result := True;
end;

function logTimestamp:string;
begin result:=formatDatetime(timeformat_log, now)+'> ' end;


end.
