unit SrcAndrq;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;


  function ImportFromAndrq(srcPth : string; memo : TMemo) : Boolean;
//  function  str2int(s:RawByteString):integer; overload;
//  function  str2int(p:pointer):integer; overload;
(*
  function StrToUTF8(const Value: AnsiString): RawByteString; OverLoad;
 {$IFDEF UNICODE}
  function StrToUTF8(const Value: UnicodeString): RawByteString; OverLoad;
 {$ENDIF UNICODE}
*)

implementation
  uses
    RDFileUtil,
    RnQZip, //historyrnq,
//    RnQDialogs, RQUtil,
//    RQUtil,
    RnQLangs,
    RDUtils, RnQBinUtils,
    RnQ2sql,
 {$IFDEF UNICODE}
    AnsiStrings,
 {$ENDIF UNICODE}
//   DISQLite3Api,
  ASGSQLite3Api,
//    ICQflap,
    rnq2Base, StrUtils;

// costants for files
const
  userthemeFilename  ='user.theme.ini';
  automsgFilename    ='automsg.ini';
  OldconfigFileName  ='andrq.ini';
  configFileName     ='rnq.ini';
  groupsFilename     ='groups.ini';
  inboxFilename      ='inbox';
  outboxFilename     ='outbox';
  macrosFilename     ='macros';
  dbFilename         ='db';
  uinlistFilename    ='uinlists';
  extstatusesFilename='extstatuses';
  SpamQuestsFilename ='spamquests.txt';
  reopenchatsFileName='reopen.list.txt';
  proxiesFilename    ='proxies.list.txt';
  CheckInvisFileName1='check.invisible.list.txt';

  rosterFileName1    ='contact.list.txt';
  visibleFileName1   ='visible.list.txt';
  invisibleFileName1 ='invisible.list.txt';
  ignoreFileName1    ='ignore.list.txt';
  nilFilename1       ='not.in.list.txt';
  retrieveFilename1  ='retrieve.list.txt';
//  packetslogFilename='packets.log';
//  myinfoFilename    ='myinfo';
//  langFilename='lang.txt';
//  spamsFilename = '0spamers';
  IF_UTF8_TEXT = (1 shl 8) or (1 shl 9);
  IF_CODEPAGE_MASK = (1 shl 8) or (1 shl 9) or (1 shl 10);

  avtPath = 'Devils\';

  SysCList_Roster  = 1;
  SysCList_Visible = 2;
  SysCList_Invis   = 3;
//  SysCList_TempVis = 4;
//  SysCList_Spam    = 5;
  SysCList_Ignore  = 6;
  SysCList_NIL     = 7;
  SysCList_Reopen  = 8;
  SysCList_ChkInvis= 9;


var
  myUID : AnsiString;


{Convert string from UTF-8 format into ASCII}
{function UTF8ToStr(const Value: AnsiString): AnsiString;
var
  buffer: Pointer;
  BufLen: LongWord;
begin
  BufLen := Length(Value) + 4;
  GetMem(buffer, BufLen);
  FillChar(buffer^, BufLen, 0);
  MultiByteToWideChar(CP_UTF8, 0, @Value[1], BufLen - 4, buffer, BufLen);
  Result := WideCharToString(buffer);
  FreeMem(buffer, BufLen);
end;
{function UTF8ToStr(const Value: AnsiString): String;
var
  buffer: Pointer;
  BufLen: LongWord;
  str : AnsiString;
begin
  BufLen := Length(Value) + 4;
  GetMem(buffer, BufLen);
  FillChar(buffer^, BufLen, 0);
  MultiByteToWideChar(CP_UTF8, 0, @Value[1], BufLen - 4, buffer, BufLen);
  Result := WideCharToString(buffer);
  FreeMem(buffer, BufLen);
end;}
(*
{Convert string from UTF-8 format into ASCII}
function UTF8ToStr(const Value: RawByteString): String;
const
  MB_ERR_INVALID_CHARS         = 8;
var
  buffer: Pointer;
  BufLen: LongWord;
//  str : AnsiString;
  l : Integer;
begin
  if Value = '' then
   begin
    Result := '';
    Exit;
   end;
  BufLen := Length(Value)*2 + 6;
  GetMem(buffer, BufLen);
  FillChar(buffer^, BufLen, 0);
//  MultiByteToWideChar(CP_UTF8, 0, @Value[1], BufLen - 4, buffer, BufLen);
 {$IFDEF UNICODE}
  l := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, PAnsiChar(Value), Length(Value), buffer, BufLen);
//  l := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(Value), Length(Value), buffer, BufLen);
 {$else nonUNICODE}
  l := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(Value), Length(Value), buffer, BufLen);
 {$ENDIF UNICODE}
//  Result := WideCharToString(buffer);
//  WideCharLenToStrVar(buffer,
//  str := LStrFromPWChar(buffer);
//  str := PWideChar(buffer);
  if l > 0 then
    Result := WideCharToString(buffer)
   else
    Result := '';
//  Result := str;
  FreeMem(buffer, BufLen);
end;

{Convert string from UTF-8 format mixed with standart ASCII symbols($00..$7f)}
function UTF8ToStrSmart(const Value: RawByteString): String;
var
  Digit: AnsiString;
  str : String;
  i: Word;
  HByte: Byte;
  Len: Byte;
begin
  Result := '';
  if Value = '' then Exit;
  Len := 0;
 {$IFNDEF UNICODE}
  str := UTF8Decode(Value);
 {$else UNICODE}
  str := UTF8ToStr(Value);
 {$ENDIF UNICODE}
  If (str='')or(str = value) Then
   Begin
    Result:=Value;
    Exit
   End;
  for i := 1 to Length(Value) do
  begin
    if Len > 0 then
    begin
      Digit := Digit + Value[i];
      Dec(Len);
      if Len = 0 then
       begin
        str := UTF8ToStr(Digit);
        if str > '' then
          Result := Result + str
        else
          Result := Result + Digit;
       end;
    end else
    begin
      HByte := byte(Value[i]);
      if HByte in [$00..$7f] then       //Standart ASCII chars
        Result := Result + Value[i]
      else begin
        //Get length of UTF-8 char
        if HByte and $FC = $FC then
          Len := 6
        else if HByte and $F8 = $F8 then
          Len := 5
        else if HByte and $F0 = $F0 then
          Len := 4
        else if HByte and $E0 = $E0 then
          Len := 3
        else if HByte and $C0 = $C0 then
          Len := 2
        else begin
          Result := Result + Value[i];
          Continue;
        end;
        Dec(Len);
        Digit := Value[i];
      end;
    end;
  end;
end;

procedure StrSwapByteOrder(Str: PWideChar);
// exchanges in each character of the given string the low order and high order
// byte to go from LSB to MSB and vice versa.
// EAX contains address of string
asm
       PUSH    ESI
       PUSH    EDI
       MOV     ESI, EAX
       MOV     EDI, ESI
       XOR     EAX, EAX // clear high order byte to be able to use 32bit operand below
@@1:
       LODSW
       OR      EAX, EAX
       JZ      @@2
       XCHG    AL, AH
       STOSW
       JMP     @@1
@@2:
       POP     EDI
       POP     ESI
end;

{function UnUTF(const s : AnsiString) : WideString;
var
//  ss : RawString;
  ss : AnsiString;
begin
//  result := s;
  if (Length(s) > 1)
     and ((s[1] < #5)or(s[2] < #5) or((s[1] = #255)and (s[2] = #254)))
     and not odd(Length(s)) then
   begin
     Result := PWideChar(s);
     if (s[1] < #5) then
      begin
       StrSwapByteOrder(PWideChar(result));
      end;
   end
   else
    begin
      ss := UTF8ToStrSmart(s);
    result := ss;
    end;
end;}

procedure SwapWordByteOrder(P: PAnsiChar; Len: Cardinal);
var
  B: AnsiChar;
begin
  while Len > 0 do
  begin
    B := P[0];
    P[0] := P[1];
    P[1] := B;
    Inc(P, 2);
    Dec(Len, 2);
  end;
end;

function UnUTF(const s : AnsiString) : String;
{$IFNDEF UNICODE}
var
//  ss : RawString;
  ss : AnsiString;
{$ENDIF UNICODE}
begin
//  result := s;
  if (Length(s) > 1)
     and ((s[1] < #5)or(s[2] < #5) or((s[1] = #255)and (s[2] = #254)))
     and not odd(Length(s)) then
   begin
   {$IFDEF UNICODE}
     Result := PWideChar(s);
     if (s[1] < #5) then
      begin
//        StrSwapByteOrder(PWideChar(result));
//        SwapShort(@Result[1], ByteLength(Result));
        SwapWordByteOrder(PAnsiChar(Result), ByteLength(Result));
      end;
   {$ELSE nonUNICODE}
     ss := s;
     if (ss[1] < #5) then
//      StrSwapByteOrder(PWideChar(ss));
//       SwapShort(@ss[1], Length(ss));
       SwapWordByteOrder(PAnsiChar(ss), Length(ss));
     result := WideCharToString(PWidechar(ss));
   {$ENDIF UNICODE}
   end
   else
    result := UTF8ToStrSmart(s);
//    result := UTF8ToStrSmart2(s);
end;

{Convert string to UTF8 format}
function StrToUTF8(const Value: AnsiString): RawByteString;
var
  buffer: Pointer;
  ResLen, BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
   begin
    Result := '';
    exit;
   end;
  BufLen := Length(Value) * 4;
  GetMem(buffer, BufLen); FillChar(buffer^, BufLen, 0);
//  GetMem(lpBuf, BufLen); FillChar(lpBuf^, BufLen, 0);
  SetLength(Result, BufLen);
  StringToWideChar(Value, buffer, BufLen);
  ResLen := WideCharToMultiByte(CP_UTF8, 0, buffer, -1, PAnsiChar(Result), BufLen, nil, nil);
  FreeMem(buffer, BufLen);

  SetLength(Result, ResLen-1);
//  CopyMemory(@Result[1], lpBuf, ResLen);
//  Result := PAnsiChar(lpBuf);
//  FreeMem(lpBuf, BufLen);
end;

 {$IFDEF UNICODE}
function StrToUTF8(const Value: UnicodeString): RawByteString;
var
//  buffer: Pointer;
  ResLen, BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
    exit('');
  BufLen := Length(Value) * 4;
//  GetMem(buffer, BufLen); FillChar(buffer^, BufLen, 0);
//  GetMem(lpBuf, BufLen); FillChar(lpBuf^, BufLen, 0);
//  StringToWideChar(Value, buffer, BufLen);
//  Buffer := @Value[1];
  SetLength(Result, BufLen);
  ResLen := WideCharToMultiByte(CP_UTF8, 0, @Value[1], Length(Value), PAnsiChar(Result), BufLen, nil, nil);
 // ResLen includes the byte for the terminating null character.

 //  FreeMem(buffer, BufLen);
//  Result := PAnsiChar(lpBuf);
//  FreeMem(lpBuf, BufLen);
  SetLength(Result, ResLen); //
end;
 {$ENDIF UNICODE}

*)

const
  DBFK_OLDUIN      = 00;
  DBFK_NICK        = 01;
  DBFK_FIRST       = 02;
  DBFK_LAST        = 03;
  DBFK_DISPLAY     = 08;
  DBFK_SENDTRANSL  = 32;
  DBFK_UID         = 111;
  DBFK_BIRTHL      = 112;

(*
  DBFK_EMAIL       = 04;
  DBFK_CITY        = 05;
  DBFK_STATE       = 06;
  DBFK_ABOUT       = 07;
  DBFK_QUERY       = 09;
  DBFK_ZIP         = 10;
  DBFK_COUNTRY     = 11;
  DBFK_BIRTH       = 12;
  DBFK_LANG        = 13;
  DBFK_HOMEPAGE    = 14;
  DBFK_CELLULAR    = 15;
  DBFK_IP          = 16;
  DBFK_AGE         = 17;
  DBFK_GMT         = 18;
  DBFK_GENDER      = 19;
  DBFK_GROUP       = 20;
  DBFK_LASTUPDATE  = 21;
  DBFK_LASTONLINE  = 22;
//  DBFK_LASTMSG     = 23;   DON'T USE, it was badly updated
  DBFK_LASTMSG     = 24;
  DBFK_NOTES       = 25;
  DBFK_DONTDELETE  = 26;
  DBFK_ASKEDAUTH   = 27;
  DBFK_MEMBERSINCE = 28;
  DBFK_ONLINESINCE = 29;
  DBFK_SMSABLE     = 30;
  DBFK_NODB        = 31;
  DBFK_INTERESTS   = 33;

  DBFK_WORKPAGE    = 34;
  DBFK_WORKSTNT    = 35; // Должность
  DBFK_WORKDEPT    = 36; // Департамент
  DBFK_WORKCOMPANY = 37; // Компания
  DBFK_WORKCOUNTRY = 38;
  DBFK_WORKZIP     = 39;
  DBFK_WORKADDRESS = 40;
  DBFK_WORKPHONE   = 41;
  DBFK_WORKSTATE   = 42;
  DBFK_WORKCITY    = 43;

  DBFK_SSIID       = 113;
  DBFK_Authorized  = 114;
  DBFK_ImpString   = 115;
  DBFK_ICONSHOW    = 116;
  DBFK_ICONMD5     = 117;
  DBFK_MARSTATUS   = 120;
*)

function str2db(const s:RawByteString; var resStr : string) : Boolean;
//var
//  fields : TupdFields;
//  dat   : TDate;
//  c:Tcontact;
  function getDateTime(const str : RawByteString) : TDateTime; Inline;
   begin
     system.move(str[1], Result, 8);
   end;
  function InsertDBval(const pUID, pNICK, pFIRST, pLAST, pDISPLAY : String;
                       pSENDTRANSL : Byte; pBIRTHL : TDate;
                       const pData : RawByteString) : Boolean;
  var
//    InsDBStmt : sqlite3_stmt;
    InsDBStmt : TSQLite3StmtHandle;
    Tail : PAnsiChar;
    ss1 : RawByteString;
    ss2 : RawByteString;
    ss3 : RawByteString;
    ss4 : RawByteString;
    ss5 : RawByteString;
  begin
        try
          begin
//           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertDBrow), Length(SQLInsertDBrow), @InsDBStmt, @Tail);
           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertDBrow), Length(SQLInsertDBrow), InsDBStmt, Tail);
           ss1 := StrToUTF8(pUID);
           sqlite3_bind_text(InsDBStmt, 1, PAnsiChar(ss1), length(ss1), SQLITE_STATIC);
           ss2 := StrToUTF8(pDISPLAY);
           sqlite3_bind_text(InsDBStmt, 2, PAnsiChar(ss2), length(ss2), NIL);
           ss3 := StrToUTF8(pNICK);
           sqlite3_bind_text(InsDBStmt, 3, PAnsiChar(ss3), length(ss3), NIL);
           ss4 := StrToUTF8(pFIRST);
           sqlite3_bind_text(InsDBStmt, 4, PAnsiChar(ss4), length(ss4), NIL);
           ss5 := StrToUTF8(pLAST);
           sqlite3_bind_text(InsDBStmt, 5, PAnsiChar(ss5), length(ss5), NIL);
           sqlite3_bind_double(InsDBStmt, 6, pBIRTHL);
           sqlite3_bind_int (InsDBStmt, 7, pSENDTRANSL);
           sqlite3_bind_blob(InsDBStmt, 8, PAnsiChar(pData), Length(pData), nil);
          end;
         if Sqlite3_Step(InsDBStmt) = SQLITE_ROW then
           begin
//             Result := True;
           end;
//         SQLite3_Reset(InsAVTStmt);
         SQLite3_Finalize(InsDBStmt);
        finally
        end;
  end;
var
  t,l,i:integer;
  d: RawByteString;
  curUID : String;
  cntNICK,
  cntFIRST,
  cntLAST,
  cntDISPLAY : String;
  cntSENDTRANSL : Byte;
  cntBIRTHL : TDate;
  bData : RawByteString;
begin
  Result := FALSE;
//  C:=NIL;  // shut up compiler
  i:=0;
  curUID := '';
  bData := '';
  cntSENDTRANSL := 0;
  cntBIRTHL := 0;
  resStr := '';
  if s = '' then
   begin
     result := False;
     resStr := getTranslation('File DB is clear or not found');
     Exit;
   end;
  while i < length(s) do
  begin
    if length(s)-pred(i) < 8 then
     begin
      resStr := getTranslation('The contacts database is corrupted, some data is lost');
      exit;
     end;
   try
    t:=dword_LEat(@s[i+1]); // 1234
    l:=dword_LEat(@s[i+5]); // 5678
    if length(s)-pred(i) < l then
      begin
      resStr := getTranslation('The contacts database is corrupted, some data is lost');
      exit;
      end;
    d:=copy(s,i+9,l);
    inc(i, 8+l);
    if (t <> DBFK_OLDUIN) AND (t <> DBFK_UID) AND (curUID ='') then
     Continue;
    if (curUID > '') and
        ((t = DBFK_OLDUIN) or
         ((t = DBFK_UID) AND (curUID <> UnUTF(d)))) then
     begin
      InsertDBval(curUID, cntNICK, cntFIRST, cntLAST, cntDISPLAY,
                  cntSENDTRANSL, cntBIRTHL, bData);
      curUID := '';
      bData := '';
      cntNICK  := '';
      cntFIRST := '';
      cntLAST  := '';
      cntDISPLAY := '';
      cntSENDTRANSL := 0;
      cntBIRTHL := 0;
     end;
    case t of
      DBFK_OLDUIN: if str2int(d) > 0 then curUID := IntToStr(str2int(d));
      DBFK_UID: if d > '' then curUID := UnUTF(d);

      DBFK_DISPLAY: cntDISPLAY := UnUTF(d);
      DBFK_NICK:    cntNICK := UnUTF(d);
      DBFK_FIRST:   cntFIRST := UnUTF(d);
      DBFK_LAST:    cntLAST := UnUTF(d);
      DBFK_SENDTRANSL: cntSENDTRANSL := byte(d[1]);
      DBFK_BIRTHL: cntBIRTHL := getDateTime(d);
//      DBFK_NODB:    addField('nodb', byte(d[1]));
//      DBFK_DONTDELETE: addField('dontdelete', byte(d[1]));
//      DBFK_ImpString: addField('ImpString', d);
//      DBFK_ICONSHOW: addField('iconShow', byte(d[1]));
//      DBFK_ICONMD5: addField('ICONMD5', d);
     else
       bData := bData + TLV2_IFNN(t, d);
//      c.about := c.about + CRLF + IntToStr(t) + ' - ' + d;
     end;//case
//     mineDB.Commit;
     Application.ProcessMessages;
   except
   end;
  end;
   if (curUID > '') then
     begin
      InsertDBval(curUID, cntNICK, cntFIRST, cntLAST, cntDISPLAY,
                  cntSENDTRANSL, cntBIRTHL, bData);
     end;
  Result := TRUE;
  resStr := getTranslation('DB loaded');
end; // str2db

(*
function loadDB(path : String; var res : String):boolean;
var
  s : String;
  zf : TZipFile;
begin
  if FileExists(path+dbFileName) then
    s := loadFile(path+dbFileName)
   else
    if FileExists(path+dbFileName + '3') then
      begin
       zf := TZipFile.Create;
       zf.LoadFromFile(path+dbFileName + '3');
       s := zf.Uncompressed[0];
       zf.Free;
      end
   else
     s := '';
//    if FileExists(userPath+dbFileName + '2') then
//      s := ZDecompressStrEx(loadFile(userPath+dbFileName + '2'))
//     else
  result:= str2db(s, res)
end; // loadDB
*)

function CList_fromString(ListType : Byte; const s: RawByteString):boolean;
var
  i:integer;
  s1 : AnsiString;
  ofs : Integer;
  len : Integer;
begin
 result:=TRUE;
 ofs := 1;
// i := 1;
 len := Length(s);
 if len = 0 then
   Exit;
 beforeInsertCList;
 while ofs<Len do
  begin
  //  i:=pos(#10,s);
    i:=posEx(AnsiString(#10),s, ofs);
    if (i>1) and (s[i-1]=#13) then
      dec(i);
    if i=0 then
      i:= Len+1;
  //  s1 := copy(s,1,i-1);
    s1 := copy(s, ofs, i-ofs);
    try
      InsertSysCList(ListType, s1);
     except
      result:=FALSE
    end;
    if s[i]=#13 then
      inc(i);
  //  system.delete(s,1,i);
    ofs := i+1;
  end;
 AfterInsertCList
end; // fromString

function str2pref(s : RawByteString; var res : String):boolean;
  function addPrefBlob(const key : String;
                       const pData : RawByteString) : Boolean;
  var
//    InsPrefStmt : sqlite3_stmt;
    InsPrefStmt : TSQLite3StmtHandle;
    Tail : PAnsiChar;
    ss1 : RawByteString;
  begin
        try
          begin
//           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertPref), Length(SQLInsertPref), @InsPrefStmt, @Tail);
           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertPref), Length(SQLInsertPref), InsPrefStmt, Tail);
           ss1 := StrToUTF8(key);
           sqlite3_bind_text(InsPrefStmt, 1, PAnsiChar(ss1), length(ss1), SQLITE_STATIC);
           sqlite3_bind_int (InsPrefStmt, 2, -1);
//           sqlite3_bind_blob(InsPrefStmt, 3, PAnsiChar(pData), Length(pData), nil);
           sqlite3_bind_text(InsPrefStmt, 3, PAnsiChar(pData), length(pData), SQLITE_STATIC);
          end;
         if Sqlite3_Step(InsPrefStmt) = SQLITE_ROW then
           begin
//             Result := True;
           end;
//         SQLite3_Reset(InsPrefStmt);
         SQLite3_Finalize(InsPrefStmt);
        finally
        end;
  end;
var
  l: RawByteString;
  key : String;
  hhh : AnsiString;
  pp : PAnsiChar;
  p1, p2, len, m : Integer; // Position of CRLF
//  lastVersion:integer;
//  i:integer;
begin
  Result := False;
  if s = '' then exit;
  p1 := 1;
  p2 := 1;
  len := Length(s);
  while p2 > 0 do
  begin
    p2 := PosEx(CRLF, s, p1);
    if p2 > 0 then
      l := Copy(s, p1, p2-p1)
     else
      l := Copy(s, p1, len);
    p1 := p2 + 2;
//    l:=chop(CRLF,cfg);
//    hhh := LowerCase(chop(AnsiString('='),l));
    m := pos(RawByteString('='), l);
    hhh := Trim(LowerCase(Copy(l, 1, m-1)));
    delete(l, 1, m);
    pp := PAnsiChar(hhh);
    key := pp;
    if key > '' then
      addPrefBlob(key, l);
  end;
  res := 'Preferences loaded';
  Result := True;
end;

function str2ExSts(s : RawByteString; var res : String):boolean;
  function addExSts(const id, cap, caption, desc : String) : Boolean;
  var
//    InsExStsStmt : sqlite3_stmt;
    InsExStsStmt : TSQLite3StmtHandle;
    Tail : PAnsiChar;
    ss1 : RawByteString;
    ss2 : RawByteString;
    ss3 : RawByteString;
    ss4 : RawByteString;
  begin
        try
          begin
//           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertExSts), Length(SQLInsertExSts), @InsExStsStmt, @Tail);
           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertExSts), Length(SQLInsertExSts), InsExStsStmt, Tail);
           ss1 := StrToUTF8(id);
           sqlite3_bind_text(InsExStsStmt, 1, PAnsiChar(ss1), length(ss1), SQLITE_STATIC);
           ss2 := StrToUTF8(cap);
           sqlite3_bind_text(InsExStsStmt, 2, PAnsiChar(ss2), length(ss2), SQLITE_STATIC);
           ss3 := StrToUTF8(caption);
           sqlite3_bind_text(InsExStsStmt, 3, PAnsiChar(ss3), length(ss3), SQLITE_STATIC);
           ss4 := StrToUTF8(desc);
           sqlite3_bind_text(InsExStsStmt, 4, PAnsiChar(ss4), length(ss4), SQLITE_STATIC);
          end;
         if Sqlite3_Step(InsExStsStmt) = SQLITE_ROW then
           begin
//             Result := True;
           end;
//         SQLite3_Reset(InsPrefStmt);
         SQLite3_Finalize(InsExStsStmt);
        finally
        end;
  end;
var
  k, line: RawByteString;
  id, cap, caption, desc : String;
//  key : String;
//  hhh : AnsiString;
//  pp : PAnsiChar;
//  p1, p2, len, m : Integer; // Position of CRLF
//  lastVersion:integer;
//  i:integer;
begin
  Result := False;
  if s = '' then exit;
  id := '';
  cap := '';
  caption := '';
  Desc := '';
  while s>'' do
  begin
   line:=chopLine(s);
   k:= chop(AnsiString('='),line);
   k := trim(k);
   line:=trim(line);
   if isOnlyDigits(k) then
     try
        if id > '' then
          addExSts(id, cap, caption, desc);
       id := k;
       cap := UnUTF(line);
       caption := '';
       Desc := '';
     except
//       setlength(a,length(a)-1);
     end
   else
     if k='caption' then
       try
          caption := UnUTF(Copy(line, 1, $FF));
       except
       end
     else
       if k='desc' then
         try
           Desc := UnUTF(StringReplace(Copy(line, 1, $FF), AnsiString('\n'), CRLF, [rfReplaceAll]));
         except
         end;
  end;
  if id > '' then
    addExSts(id, cap, caption, desc);
  res := 'ExStatuses loaded';
  Result := True;
end;

function loadLists(path: String; var res: String):boolean;
var
  s : RawByteString;
  dbFile : String;
  res1 : String;
  BaseType : Byte;
  sp : TThemeSourcePath;
begin
  if FileExists(path+dbFileName+'5') then
    begin
      BaseType := 5;
      dbFile := dbFileName+'5';
      sp.path := '';
      sp.pathType := pt_zip;
    end
   else
  if FileExists(path+dbFileName+'4') then
    begin
      BaseType := 4;
      dbFile := dbFileName+'4';
      sp.path := '';
      sp.pathType := pt_zip;
    end
   else
     begin
      BaseType := 1;
      dbFile := dbFileName;
      sp.path := path;
      sp.pathType := pt_path;
     end;
  if BaseType > 1 then
    begin
      sp.zp := TZipFile.Create;
      sp.zp.LoadFromFile(path + dbFile);
    end;

  s := loadFile(sp, rosterFileName1);
  if CList_fromString(SysCList_Roster, s) then
    res := res + CRLF + 'Roster list loaded';

  s := loadFile(sp, visibleFileName1);
  CList_fromString(SysCList_Visible, s);

  s := loadFile(sp, invisibleFileName1);
  CList_fromString(SysCList_Invis, s);

  s := loadFile(sp, ignoreFileName1);
  CList_fromString(SysCList_Ignore, s);

  s := loadFile(sp, nilFilename1);
  CList_fromString(SysCList_NIL, s);

  s := loadFile(sp, reopenchatsFileName);
  CList_fromString(SysCList_Reopen, s);

  s := loadFile(sp, CheckInvisFileName1);
  CList_fromString(SysCList_ChkInvis, s);

  res1 := '';
  s := loadFile(sp, dbFilename);
  if str2db(s, res1) then
    res := res + CRLF + res1;

  res1 := '';
  s := loadFile(sp, configFileName);
  if str2pref(s, res1) then
    res := res + CRLF + res1;

  res1 := '';
  s := loadFile(sp, extstatusesFilename);
  if str2ExSts(s, res1) then
    res := res + CRLF + res1;

  if BaseType > 1 then
    sp.zp.Free;

  result:= True;
end; // loadDB

function LoadAvt(pth : String) : Boolean;
  procedure AddAVT(fn : String; bType : Byte; blob : RawByteString);
  var
    i : Integer;
    hash : RawByteString;
//    InsAVTStmt : SQLite3_Stmt;
    InsAVTStmt : TSQLite3StmtHandle;
    Tail : PAnsiChar;
  begin
    i := Pos('.', fn);
    if i = 33 then
      begin
        SetLength(hash, 16);
//        HexToBin(copy(fn, 1, 32), @hash[1], 16);
        HexToBin(PChar(fn), @hash[1], 16);
        try
          begin
//           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertAVT), Length(SQLInsertAVT), @InsAVTStmt, @Tail);
           SQLite3_Prepare_v2(MineDB, PAnsiChar(SQLInsertAVT), Length(SQLInsertAVT), InsAVTStmt, Tail);

           sqlite3_bind_blob(InsAVTStmt, 1, PAnsiChar(hash), 16, NIL);
           sqlite3_bind_int (InsAVTStmt, 2, bType);
           sqlite3_bind_blob(InsAVTStmt, 3, PAnsiChar(blob), Length(blob), nil);
          end;
         if Sqlite3_Step(InsAVTStmt) = SQLITE_ROW then
           begin
//             Result := True;
           end;
//         SQLite3_Reset(InsAVTStmt);
         SQLite3_Finalize(InsAVTStmt);
        finally
        end;
      end;
  end;

var
  vPath : String;
  sr:TsearchRec;
  bFile : RawByteString;
  bType : Byte;
  cnt : Integer;
//var
//  sel, sub : string;
//  msg, inf : String;
//  I: Integer;
begin
   Result := false;
//   sub := '';
//   sel := '';
  vPath := pth + avtPath;
  if (vPath='') or not directoryExists(vPath) then exit;

  vPath:=includeTrailingPathDelimiter(vPath);
//  for I := 0 to Length(hash) - 1 do
  cnt := 0;
//   hasAvatar := False;
//   if (hash > '') then
   begin
     if FindFirst(vPath+ '*.*', faAnyFile, sr) = 0 then
      repeat
//      hasAvatar := True;
       if (sr.name<>'.') and (sr.name<>'..') then
        begin
         if pos('.photo.', sr.Name) > 1 then
//           bType := AVTTypePhoto
           continue;
//          else
         if pos('.xml.', sr.Name) > 1 then
           bType := AVTTypeXMLPic
          else
         if lowercase(ExtractFileExt(sr.Name)) = '.xml' then
           bType := AVTTypeXML
          else
           bType := AVTTypePic;
         bFile := loadFileA(vPath+sr.Name);
         if Length(bFile) > 0 then
          begin
           AddAVT(sr.Name, bType, bFile);
           inc(cnt);
          end;
        end;
      until findNext(sr) <> 0;
      findClose(sr);
   end;
  Result := True;
end;


function  GetStream(fn : String) : TStream;
//var
// fs : TFileStream;
begin
  result := NIL;
  if not FileExists(fn) then exit;
  try
    result := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
  except
    result := NIL;
  end;
end;

  function dupString(s: RawByteString): RawByteString;
  begin result:=copy(s,1,length(s)) end;

   procedure decritt(var s: RawByteString; key:integer); assembler; register;
     asm
     mov ecx, key
     mov dl, cl
     shr ecx, 20
     mov dh, cl

     mov esi, s
     mov esi, [esi]
     or  esi, esi    // nil string
     jz  @OUT
     mov ah, 10111000b

     mov ecx, [esi-4]
     or  ecx, ecx
     jz  @OUT
   @IN:
     mov al, [esi]
     xor al, ah
     rol al, 3
     xor al, dh
     sub al, dl

     mov [esi], al
     inc esi
     ror ah, 3
     dec ecx
     jnz @IN
   @OUT:
   end; // decritt

  function decritted(s: RawByteString; key:integer): RawByteString;
  begin
   result:=dupString(s);
   decritt(result, key);
  end;

function LoadHistoryFile(path, fn : string) : Boolean;
const
  EI_flags=1;
  EI_UID = 11;

const
  Max_Event_ID = 1000000;
  CRYPT_SIMPLE=0;
  CRYPT_KEY1=1;
  HI_event=-1;
  HI_hashed=-2;
  HI_cryptMode=-3;

//  function getByte:byte;
  function getByte(str : TMemoryStream):byte; inline;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;

//  function getDatetime:Tdatetime;
  function getDatetime(str : TMemoryStream):Tdatetime; inline;
  begin
    str.Read(result, 8);
//    inc(cur,8)
  end;

//  function getInt:integer;
  function getInt(str : TMemoryStream):integer; inline;
  begin
    str.Read(result, 4);
//    inc(cur,4);
  end;

//  function getString: RawByteString;
  function getString(str : TMemoryStream): RawByteString; inline;
  var
    i : Integer;
  begin
//    i := getInt;
    i := getInt(str);
    SetLength(Result, i);
    str.Read(result[1], i);
//    inc(cur,length(result))
  end;

var
  ev:Thevent;
  str:TMemoryStream;

  procedure parseExtrainfo;
  var
    code,next,extraEnd:integer;
    cur : Integer;
    s : AnsiString;
  begin
    cur := 1;
    extraEnd := 4+getInt(str);
    inc(cur, 4);
  while cur < extraEnd do
    begin
    code:=getInt(str);
    inc(cur, 4);
//    inc(cur, 4);
    next:=cur+ getInt(str) + 4;
    case code of
      EI_flags:
        begin
         ev.flags:=getInt(str);
//         inc(cur, 4);
        end;
      EI_UID:
        begin
//          s := str.re
          s := getString(str);
           if s = myUID then
             begin
               ev.who  := myUID;
               ev.whom := fn;
               ev.isSend := 1;
             end
            else
             ev.who := s;
        end;
      end;
    cur:=next;
    end;
  end; // parseExtraInfo
var
  str2 : TStream;
//  thisCnt, thisCnt2 : TRnQcontact;
  Cnt1I, Cnt2I : Int64;
//  cur:integer;
var
  cryptMode :byte;
  len, rows : Int64;
  s : AnsiString;
//  iu : TUID;
  myNum : Integer; 
  i : Integer;
  a, b : Integer;
  DecrKey : Integer;
  curPos : Int64;
begin
//  loading := True;
 try
//  cur:=1;
   rows := 0;
  myNUM := StrToIntDef(myUID, 0);
  cryptMode := CRYPT_SIMPLE;
//  hashed:='';
  str2 := GetStream(path + fn);
  Cnt2I := 0;
  Cnt1I := 0;
  if not Assigned(str2) then
    begin
//      loaded := True;
      result := false;
      exit;
    end;
  str := TMemoryStream.Create;
  str.LoadFromStream(str2);
  str2.Free;
  len := str.Size;
//  str.Position := 0;
  str.Seek(0, 0);
  curPos := 0;
//while str.Position < len do
  if len > 0 then
  repeat
  begin
   ev := Thevent.Create;
   try
       ev.ID := Max_Event_ID;
    //  FillChar(Ev, sizeOf(Ev), #0);
       Ev.whom := myUID;
       ev.isSend := 0;
    //  ev.fpos:=cur-1;
    //  ev.fpos:= str.Position;
      ev.fpos:= curPos;
      case getInt(str) of
    //  case getInt1(str) of
        HI_event:
          begin
          ev.cryptMode := cryptMode;
//          ev.kind      := getByte;
          ev.kind      := getByte(str);
          begin
    //        iu := IntToStr(getInt);
            i := getInt(str);
            if i > 0 then
              begin
               if i = myNUM then
                 begin
                   ev.who  := myUID;
                   ev.whom := fn;
                   ev.isSend := 1;
                 end
                else
                   ev.who  := IntToStr(i);
              end
            else
             begin
    //           thisCnt := NIL;
               ev.who  := '';
             end
          end;
          DecrKey := i;
    //      curEv.who := IntToStr(getInt);
          ev.when      := getDatetime(str);
          parseExtrainfo;
          ev.Bin      := getString(str);
    //      add(@ev);
         if ev.kind in [EK_url,EK_msg,EK_authReq,EK_automsg] then
          begin
           s := decritted(ev.Bin, DecrKey);
           ev.Bin := '';
           a := pos(AnsiString('<RnQImage>'), s);
           while a > 0 do
            begin
              b := PosEx(AnsiString('</RnQImage>'), s, a+10);
              if b <= 5 then Break;
//              ev.Bin := ev.Bin + Copy(s, a+10, b-a-10);
              ev.Bin := ev.Bin + Copy(s, a, b+11-a);
              Delete(s, a, b+11-a);
              a := pos(AnsiString('<RnQImage>'), s);
            end;
           a := pos(AnsiString('<RnQImageEx>'), s);
           while a > 0 do
            begin
              b := PosEx(AnsiString('</RnQImageEx>'), s, a+12);
              if b <= 5 then Break;
//              ev.Bin := ev.Bin + Copy(s, a+12, b-a-12);
              ev.Bin := ev.Bin + Copy(s, a, b+13-a);
              Delete(s, a, b+13-a);
              a := pos(AnsiString('<RnQImageEx>'), s);
            end;
           if (ev.flags and IF_CODEPAGE_MASK) = IF_UTF8_TEXT then
             ev.TextUTF := s
            else
             ev.TextUTF := StrToUTF8(unUTF(s));
          end
         else
          if ev.kind = EK_CONTACTS then
           begin
//             ev.TextUTF := decritted(ev.Bin, DecrKey);
             ev.Bin := decritted(ev.Bin, DecrKey);
             ev.TextUTF := '';
           end
         else
//         if ev.kind = EK_statuschange then
//          begin
//          end
//         else
          begin
//           msg := '';
//           inf := ev.info;
          end;

            if InsertHist(fn, Ev) then
              inc(rows);
            Application.ProcessMessages;
          end;
    //    HI_hashed: hashed:=getString;
        HI_cryptMode:
          begin
    //      getInt; // skip length
             str.Seek(4, soFromCurrent); // skip length
           cryptMode    := getByte(Str);
          end;
        else
          begin
    //       if not quite then
    //         msgDlg(getTranslation('The history is corrupted, some data is lost'),mtError);
    //          messageDlg(getTranslation('The history is corrupted, some data is lost'),
              messageDlg('The history is corrupted, some data is lost',
                         mtError, [mbOk], 0, mbOk);
           result:=FALSE;
           exit;
          end;
        end;
   finally
     ev.Free;
   end;
  end;
  curPos := str.Position;
  until (curPos >=len);
//loaded:=TRUE;
result:=TRUE;
 finally
   if Assigned(str) then
     str.Free;
//   loading := false;
 end;
end; // fromStream


function LoadHistory(path : string; var res : String) : Boolean;
var
  sr:TsearchRec;
begin
  res := '';
    if FindFirst(path + 'History\*.', faAnyFile, sr) = 0 then
     repeat
      if (sr.name<>'.') and (sr.name<>'..') then
       begin
         beforeInsertHistory;
//         LoadHistoryFile(path + 'History\' + sr.name, sr.name);
         LoadHistoryFile(path + 'History\', sr.name);
         res := res + CRLF + logtimestamp + 'File "'+ sr.name+'" imported';
         AfterInsertHistory;
       end;
      until findNext(sr) <> 0;
     findClose(sr);
 Result := True;
end;

Function ImportFromAndrq(srcPth : string; memo : TMemo) : Boolean;
var
  s : string;
  pth : String;
  i, j : Integer;
begin
//  Result := false;
//  timeformat_log := shortdateformat+' hh:nn:ss.zzz';
  timeformat_log := 'dd.mm.yyyy'+' hh:nn:ss.zzz';
  j := 1;
  s := srcPth;
  if s[Length(s)] = PathDelim then
    SetLength(s, Length(s)-1);
  repeat
   i := j+1;
   j := posEx(PathDelim, s, i);
  until j < i;
  myUID := Copy(s, i, 20);
  memo.Lines.Add(logtimestamp + 'Begin import from "'+ srcPth+'"');
  pth := IncludeTrailingPathDelimiter(srcPth);
  s := '';
// Only History
   Result := LoadHistory(pth, s);
  if s > '' then
    memo.Lines.Add(logtimestamp + s);
  s := '';
  Result := loadLists(pth, s);
  if s > '' then
    memo.Lines.Add(logtimestamp + s);
  s := '';
  if LoadAvt(pth) then
   memo.Lines.Add(logtimestamp + 'Avatars loaded');
//  Result := loadDB(IncludeTrailingPathDelimiter(srcPth), s);
//  memo.Lines.Add(logtimestamp + s);
//  if Result then
//  createIM2base;            !!!!!!!!!!!!!!!!!!!!!!!
//  Result := true;
  memo.Lines.Add(logtimestamp + 'End import');
end;


//function str2int(s: RawByteString):integer;
//begin result:=dword_LEat(@s[1]) end;
//
//function str2int(p:pointer):integer;
//begin result:=dword_LEat(p) end;


end.
