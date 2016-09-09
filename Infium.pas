unit Infium;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

  function ImportFromInfium(srcPth : string; memo : TMemo; myuid : String) : Boolean;

implementation
uses
  StrUtils, dateUtils, rnq2Base, //flap,
  RnQ2sql;

//function LoadHistoryFile(srcPth : string; memo : TMemo) : Boolean;
//function ReadData(filename:string; output: TRichEdit):boolean;
function LoadHistoryFile(path, fn : string; myuid : String) : Boolean;
type
  QHFheader = record
    QHFmagic:  array[0..3] of byte;
    QHFdata1:  array[0..1] of byte;
    QHFdata2:  array[0..1] of byte;
    QHFnull:   array[0..9] of byte;
    QHFxxx:    array[0..15] of byte;
    QHFitems1: array[0..3] of byte;
    QHFitems2: array[0..3] of byte;
  end;
   QHFRecord = record
     recordtype: word;
     recordsize: dword;
     recordindex:  Cardinal;
     recordtime: dword;
     recordinout:  byte;
     recordmessage: widestring;
   end;
var
  tms: TMemoryStream;
  qhfhead: QHFheader;
//  qhfrec: array of QHFRecord;
  qhfrec1: QHFRecord;
  ba2:array[0..1] of byte;
  ba4:array[0..3] of byte;
  bastr,bamsg: array of byte;
  ch: char;
  utype,w,l,i,ii: word;
  dl: dword;
  clr: TColor;
  histcount: dword;
  nick,uin,msg: widestring;
  utfs: UTF8String;

  ev:Thevent;
begin
 
//  RichEdit1.Clear;
//  ComboBox1.Enabled:=false;
  result:=false;
 
  try
    tms:=TMemoryStream.Create;
    tms.LoadFromFile(path+fn);
    tms.Read(qhfhead,sizeof(qhfhead));
 
    if CompareMem(@qhfhead.QHFitems1,@qhfhead.QHFitems2,4) then
       begin
//       histcount:=r32(qhfhead.QHFitems1)
         histcount:=Cardinal(qhfhead.QHFitems1);
//         histcount := invert(Integer(histcount));
         histcount := Swap(Integer(histcount));
       end
     else
       exit;
 
    tms.Read(utype,2);    // Read 2 bytes, probably History Type
//    tms.Read(ba2,2);      // Read UIN bytecount
//    l:=r16(ba2);
    tms.Read(l,2);      // Read UIN bytecount
    l := Swap(l);
    SetLength(bastr,l+1);
    bastr[l] := 0;
    tms.Read(bastr[0],l);    // Read UIN
    uin:=UTF8Decode(pAnsiChar(bastr));
//    SetLength(uin,l);

//    tms.Read(ba2,2);      // Read nick bytecount
//    l:=r16(ba2);
    tms.Read(l,2);      // Read nick bytecount
    l := Swap(l);
    SetLength(bastr,l+1);
    bastr[l] := 0;
    tms.Read(bastr[0],l);    // Read nick
    nick:=UTF8Decode(pchar(bastr));
//    SetLength(nick,l);
//    SetLength(qhfrec, histcount);

    for i:=0 to histcount-1 do
    try
      ev:=Thevent.Create;
      msg:='';
//          tms.Read(ba2,2); // magic
//          l:=r16(ba2);
          tms.Read(l,2); // magic
          l := Swap(l);
//          qhfrec[i].recordtype:=l;
         qhfrec1.recordtype:=l;
      ev.kind := l;


 
//          tms.Read(ba4,4); // Read record SIZE
//          dl:=r32(ba4);
          tms.Read(dl,4); // Read record SIZE
//          dl := invert(Integer(dl));
          dl := Swap(Integer(dl));
//          qhfrec[i].recordsize :=dl;
         qhfrec1.recordsize :=dl;

          tms.Read(ba2,2); // Read record Index type, should be 1
          tms.Read(ba2,2); // Read record Index bytecount, should be 4
//          tms.Read(ba4,4); // Read record Index
//          dl:=r32(ba4);
          tms.Read(dl,4); // Read record Index
          dl := Swap(Integer(dl));
//          qhfrec[i].recordindex :=dl;
         qhfrec1.recordindex :=dl;
          tms.Read(ba2,2); // Read record UINblock type, should be 2
          tms.Read(ba2,2); // Read record UINblock type, should be 4
 
//          tms.Read(ba4,4); // Read record Timestamp
//          qhfrec[i].recordtime:= r32(ba4);
          tms.Read(dl,4); // Read record Timestamp
          dl := Swap(Integer(dl));
//          qhfrec[i].recordtime:= dl;
         qhfrec1.recordtime:= dl;
         ev.when := UnixToDateTime(qhfrec1.recordtime);
//          msg:=msg+DateToStr(UnixToDateTime(qhfrec[i].recordtime))+' '+TimeToStr(UnixToDateTime(qhfrec[i].recordtime));

          tms.Read(ba2,2); // Read record Flagblock type, should be 3
          tms.Read(ba2,2); // Read record Flagblock type, should be 3
//          tms.Read(qhfrec[i].recordinout,1); // Read record InOut Type
          tms.Read(qhfrec1.recordinout,1); // Read record InOut Type
          tms.Read(l,2); // Read record Flag, should be 1
          ev.flags := swap(l);
          if qhfrec1.recordinout=1 then
            begin
//             msg:='>>> ' + msg;
             ev.isSend := 1;
             ev.who := myuid;
             ev.whom := uin;
            end
           else
            begin
//             msg:='<<< ' + msg;
             ev.isSend := 0;
             ev.who := uin;
             ev.whom := myuid;
            end;
          tms.Read(ba2,2); // Read message block type, should be 4
//          tms.Read(ba2,2); // Read message size
//          l:=r16(ba2);
          tms.Read(l,2); // Read message size
          l := swap(l);
          SetLength(bamsg,l);
          tms.Read(bamsg[0],l);// Read message
 
          for ii:=0 to l-1 do  begin
              bamsg[ii]:=bamsg[ii] + ii + 1;
              bamsg[ii]:=  not bamsg[ii];  
          end;  // גמע ט גוסü רטפנ
 
          setlength(utfs,l);
          CopyMemory(pchar(utfs),@bamsg[0],l);
                          
//          qhfrec[i].recordmessage:= UTF8Decode(utfs);
         ev.TextUTF := utfs;
//          msg:=msg+' '+qhfrec[i].recordmessage;

  //        AddColoredLine(output,msg,fontcolor[qhfrec[i].recordinout],fontsize[qhfrec[i].recordinout], fontstyle[qhfrec[i].recordinout], fontname[qhfrec[i].recordinout]);
          InsertHist(Ev);
          Application.ProcessMessages;
      finally
       ev.free;    
    end;
    tms.Free;
    result:=true;
  //  ComboBox1.Enabled:=true;
 
  except
    ShowMessage('Error reading file');
  end;

end;

function LoadHistory(path : String; var res : string; myuid : String) : Boolean;
var
  sr:TsearchRec;
begin
  res := '';
    if FindFirst(path + '*.qhf', faAnyFile, sr) = 0 then
     repeat
      if (sr.name<>'.') and (sr.name<>'..') then
       begin
         beforeInsertHistory;
//         LoadHistoryFile(path + 'History\' + sr.name, sr.name);
         LoadHistoryFile(path, sr.name, myuid);
         res := res + CRLF + logtimestamp + 'File "'+ sr.name+'" imported';
         AfterInsertHistory;
       end;
      until findNext(sr) <> 0;
     findClose(sr);
 Result := True;
end;

Function ImportFromInfium(srcPth : string; memo : TMemo; myUID: String) : Boolean;
var
  s : string;
  i, j : Integer;
  timeformat_log : AnsiString;
begin
//  Result := false;
//  timeformat_log := shortdateformat+' hh:nn:ss.zzz';
  timeformat_log := 'dd.mm.yyyy'+' hh:nn:ss.zzz';
  j := 1;
  s := srcPth;
{  if s[Length(s)] = PathDelim then
    SetLength(s, Length(s)-1);
  repeat
   i := j+1;
   j := posEx(PathDelim, s, i);
  until j < i;
  myUID := Copy(s, i, 20);}
  memo.Lines.Add(logtimestamp + 'Begin import from "'+ srcPth+'"');
//  s := '';
//  Result := loadDB(IncludeTrailingPathDelimiter(srcPth), s);
//  memo.Lines.Add(logtimestamp + s);
// Only History
  s := '';
//  if Result then
   Result := LoadHistory(IncludeTrailingPathDelimiter(srcPth), s, myuid);
  memo.Lines.Add(logtimestamp + s);
//  createIM2base;            !!!!!!!!!!!!!!!!!!!!!!!
//  Result := true;
  memo.Lines.Add(logtimestamp + 'End import');
end;

end.