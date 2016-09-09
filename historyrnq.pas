{
Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit historyrnq;

interface

uses
  Windows, classes, RnQ2Base, sysutils, graphics;

const
  CRYPT_SIMPLE=0;
  CRYPT_KEY1=1;
type
  Thistory=class(Tlist)
    loaded    :boolean;
    loading   :boolean;
    cryptMode :byte;
    Token, themeToken,SmilesToken : Cardinal;
    hashed    : AnsiString;
//    function  toString:AnsiString;
    function  getAt(idx:integer):Thevent;
    procedure reset;
//    function  load(uid:AnsiString; quite : Boolean = false):boolean;
    function  load(path : String; uid:AnsiString; quite : Boolean = false):boolean;
//    function  RepaireHistoryFile(fn : String; var rslt : String) : Boolean;
   private
    function  fromStream(str:Tstream; quite : Boolean = false):boolean;
//    function  RepaireHistoryStream(str : TMemoryStream; var rslt : String) : boolean;
//    function  fromString(s:AnsiString; quite : Boolean = false):boolean;
   end; // Thistory


implementation

uses
//  globalLib, RnQLangs,
//  utilLib,
//  RnQFileUtil,
//  RQGlobal, RQUtil,
  Dialogs,
  flap;

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

const
  Max_Event_ID = 1000000;
  EI_flags=1;
//  EI_shit=3;
  EI_UID = 11;

  HI_event=-1;
  HI_hashed=-2;
  HI_cryptMode=-3;

function Thistory.load(path : String; uid:AnsiString; quite : Boolean = false):boolean;
var
  str : TStream;
  memstream : TMemoryStream;
begin
//  loadf
//  Result :=  fromString(loadFile(userPath+historyPath + uid), quite);
  str := GetStream(Path+ uid);
  if Assigned(str)  then
   begin
    str.Position := 0;
//    Result :=  fromSteam(str, quite);
    memstream := TMemoryStream.Create;
    memstream.CopyFrom(str, str.Size);
    memstream.Position := 0;
    FreeAndNil(str);
    Result :=  fromStream(memstream, quite);
    FreeAndNil(memstream);
   end
  else
   Result :=  fromStream(nil, quite);
end;

function Thistory.fromStream(str:Tstream; quite : Boolean = false):boolean;
var
  ev:Thevent;
//  thisCnt, thisCnt2 : TRnQcontact;
  Cnt1I, Cnt2I : Int64;
//  cur:integer;

  function getByte:byte;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;

  function getDatetime:Tdatetime;
  begin
    str.Read(result, 8);
//    inc(cur,8)
  end;

  function getInt:integer;
  begin
    str.Read(result, 4);
//    inc(cur,4);
  end;

  function getString:string;
  var
    i : Integer;
  begin
    i := getInt;
    SetLength(Result, i);
    str.Read(result[1], i);
//    inc(cur,length(result))
  end;

  procedure parseExtrainfo;
  var
    code,next,extraEnd:integer;
    cur : Integer;
    s : AnsiString;
  begin
    cur := 1;
    extraEnd := 4+getInt;
    inc(cur, 4);
  while cur < extraEnd do
    begin
    code:=getInt;
    inc(cur, 4);
//    inc(cur, 4);
    next:=cur+ getInt + 4;
    case code of
      EI_flags:
        begin
         ev.flags:=getInt;
//         inc(cur, 4);
        end;
      EI_UID:
        begin
//          s := str.re
          s := getString;
          ev.who := s;
        end;
      end;
    cur:=next;
    end;
  end; // parseExtraInfo
var
  len : Int64;
//  iu : TUID;
  i : Integer;
  curPos : Int64;
begin
  loading := True;
 try
//  cur:=1;
  cryptMode:=CRYPT_SIMPLE;
  hashed:='';
  Cnt2I := 0;
  Cnt1I := 0;
  if not Assigned(str) then
    begin
      loaded := True;
      result := True;
      exit;
    end;
  len := str.Size;
  str.Seek(0, 0);
  curPos := 0;
//while str.Position < len do
  if len > 0 then
  repeat
  begin
  ev:=Thevent.Create;
  ev.ID := Max_Event_ID;
//  ev.fpos:=cur-1;
//  ev.fpos:= str.Position;
  ev.fpos:= curPos;
  case getInt of
//  case getInt1(str) of
    HI_event:
      begin
      ev.cryptMode := cryptMode;
      ev.kind      := getByte;
      begin
//        iu := IntToStr(getInt);
        i := getInt;
        if i > 0 then
          begin
           ev.who  := IntToStr(i);
          end
        else
         begin
//           thisCnt := NIL;
           ev.who  := '';
         end
      end;
      ev.when      := getDatetime;
      parseExtrainfo;
      ev.Bin      := getString;
      add(@ev);
      end;
    HI_hashed: hashed:=getString;
    HI_cryptMode:
      begin
//      getInt; // skip length
         str.Seek(4, soFromCurrent); // skip length
       cryptMode    := getByte;
      end;
    else
      begin
       if not quite then
//         msgDlg(getTranslation('The history is corrupted, some data is lost'),mtError);
//          messageDlg(getTranslation('The history is corrupted, some data is lost'),
          messageDlg('The history is corrupted, some data is lost',
                     mtError, [mbOk], 0, mbOk);
       result:=FALSE;
       exit;
      end;
    end;
  end;
  curPos := str.Position;
  until (curPos >=len);
loaded:=TRUE;
result:=TRUE;
 finally
   loading := false;
 end;
end; // fromStream

(*
function Thistory.toString: AnsiString;
var
  i,dim:integer;

  procedure addStr(s:string);
  begin
  while dim+length(s) > length(result) do
    setLength(result, length(result)+10000);
  system.move(s[1], result[dim+1], length(s));
  inc(dim, length(s));
  end; // addStr

begin
result:='';
dim:=0;

{if histcrypt.enabled then
  addStr(TLV2(HI_cryptMode, char(cryptMode))
       + TLV2(HI_hashed, hashed) );
}
i:=0;
while i < count do
  begin
  addStr( getAt(i).toString );
  inc(i);
  end;
setLength(result, dim);
end; // toString
*)

function Thistory.getAt(idx:integer):Thevent;
begin
if (idx >= 0) and (idx < count) then
  result:=Thevent(items[idx])
else
//  result:=NIL
  result:=NIL
end; // getAt

procedure Thistory.reset;
var
  i:integer;
begin
  loaded:=FALSE;
  loading := True;
  i:=0;
  while i < count do
    begin
    Thevent(items[i]).free;
    inc(i);
    end;
  clear;
  loading := False;
end; // reset

{
procedure DelHistWith(uid : AnsiString);
begin
    if FileExists(userPath + historyPath + UID) then
     DeleteFile(userPath + historyPath + UID);
end;

{
function Thistory.RepaireHistoryStream(str : TMemoryStream; var rslt : String) : boolean;
var
  ev:Thevent;
//  cur:integer;

  function getByte:byte;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;
  function getDatetime:Tdatetime;
  begin
//    result:=Tdatetime((@s[cur])^);
    str.Read(result, 8);
//    inc(cur,8)
  end;
  function getInt:integer;
  begin
//    result:=integer((@s[cur])^);
    str.Read(result, 4);
//    inc(cur,4);
  end;
  function getString:string;
  var
    i : Integer;
  begin
//    result:=copy(s,cur,getInt); inc(cur,length(result))
    i := getInt;
    SetLength(Result, i);
    str.Read(result[1], i);
  end;

  procedure parseExtrainfo;
  var
    code,next,extraEnd:integer;
    cur : Integer;
  begin
    cur := 1;
    extraEnd := getInt;
    inc(cur, 4);
  while cur < extraEnd do
    begin
    code:=getInt;
    inc(cur, 4);
    next:=cur+getInt;
    case code of
      EI_flags:
        begin
         ev.flags:=getInt;
//         inc(cur, 4);
        end;
      EI_UID:
        begin
          ev.who := MainProto.getContact(getString);
        end;
      end;
    cur:=next;
    end;
  end; // parseExtraInfo
var
  len : Int64;
//  iu : TUID;
  i : Integer;
  thisCnt : TRnQcontact;
begin
//  cur:=1;
  cryptMode:=CRYPT_SIMPLE;
  hashed:='';
  if not Assigned(str) then
    begin
      loaded := True;
      result := True;
      exit;
    end;
  len := str.Size;
  thisCnt := NIL;
  str.Seek(0, 0);
while str.Position < len do
  begin
  ev:=Thevent.create;
//  ev.fpos:=cur-1;
  ev.fpos:= str.Position;
  case getInt of
    HI_event:
      begin
      ev.cryptMode := cryptMode;
      ev.kind      := getByte;
      begin
//        iu := IntToStr(getInt);
        i := getInt;
        if Assigned(thisCnt) and thisCnt.equals(i) then
          ev.who       := thisCnt
         else
          if MainProto.MyInfo.equals(i) then
            ev.who       := MainProto.MyInfo
           else
            if i > 0 then
              begin
               thisCnt := MainProto.getContact(IntToStr(i));
               ev.who  := thisCnt;
              end
             else
              begin
               thisCnt := NIL;
               ev.who  := thisCnt;
              end
      end;
      ev.when      := getDatetime;
      parseExtrainfo;
      ev.info      := getString;
      add(ev);
      end;
    HI_hashed: hashed:=getString;
    HI_cryptMode:
      begin
      getInt; // skip length
      cryptMode    := getByte;
      end;
    else
      begin
//       if not quite then
//         msgDlg(getTranslation('The history is corrupted, some data is lost'),mtError);
       result:=FALSE;
//       exit;
      end;
    end;
  end;
loaded:=TRUE;
result:=TRUE;
end;

function Thistory.RepaireHistoryFile(fn : String; var rslt : String) : Boolean;
var
  str : TStream;
  memstream : TMemoryStream;
begin
  rslt := logtimestamp + getTranslation('Begin repaire file "%s"', [fn]);

  str := GetStream(fn);
  if Assigned(str)  then
   begin
    str.Position := 0;
  //  Result :=  fromSteam(str, quite);
    memstream := TMemoryStream.Create;
    memstream.CopyFrom(str, str.Size);
    memstream.Position := 0;
    FreeAndNil(str);

    result := RepaireHistoryStream(memstream, rslt);
//    Result :=  fromSteam(memstream, quite);
    FreeAndNil(memstream);
   end;
  rslt := rslt+crlf+ logtimestamp + getTranslation('End of repaire file "%s"', [fn]);
  Result := True;
end;
}

end.
