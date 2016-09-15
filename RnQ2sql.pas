unit RnQ2sql;

interface
//   uses RQGlobal;
const
  CRLF=#13#10;
  CRLFCRLF=CRLF+CRLF;

const
  SQLCreate_CLIST_TYPES : AnsiString =
    'CREATE TABLE IF NOT EXISTS [CLIST_TYPES](' + CRLF +
    ' [ID] NUMBER(1) NOT NULL ON CONFLICT IGNORE COLLATE BINARY,' + CRLF +
    ' [DESC] CHAR(20) NOT NULL ON CONFLICT IGNORE,' + CRLF +
    ' CONSTRAINT [CLIST_TYPES_PK] PRIMARY KEY ([ID] COLLATE BINARY) ON CONFLICT IGNORE);';

  SQLData_CLIST_TYPES : AnsiString =
    'INSERT INTO [CLIST_TYPES] '+CRLF+
    ' SELECT 1, ''ROSTER'' UNION '+CRLF+
    ' SELECT 2, ''VISIBLE'' UNION '+CRLF+
    ' SELECT 3, ''INVISIBLE'' UNION '+CRLF+
    ' SELECT 4, ''TEMPVIS'' UNION '+CRLF+
    ' SELECT 5, ''SPAM'' UNION '+CRLF+
    ' SELECT 6, ''IGNORE'' UNION '+CRLF+
    ' SELECT 7, ''NIL'' UNION '+CRLF+
    ' SELECT 8, ''REOPEN'' UNION '+CRLF+
    ' SELECT 9, ''CHK_INVIS'';';
{
    'INSERT INTO [CLIST_TYPES] VALUES (1, ''ROSTER'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (2, ''VISIBLE'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (3, ''INVISIBLE'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (4, ''TEMPVIS'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (5, ''SPAM'');';{ + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (6, ''IGNORE'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (7, ''NIL'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (8, ''REOPEN'');' + CRLF +
    'INSERT INTO [CLIST_TYPES] VALUES (9, ''CHK_INVIS'');';
}
  SQLCreate_SYS_CLISTS : AnsiString =
    'CREATE TABLE IF NOT EXISTS SYS_CLISTS ('+CRLF+
    ' CLIST_TYPE NUMBER(1) NOT NULL ON CONFLICT FAIL COLLATE BINARY,'+CRLF+
    ' UID CHAR NOT NULL ON CONFLICT FAIL,'+CRLF+
    ' CONSTRAINT SYS_CLISTS_PK PRIMARY KEY (CLIST_TYPE, UID COLLATE NOCASE) ON CONFLICT FAIL);';

  SQLInsertSysCList : AnsiString = 'INSERT INTO SYS_CLISTS VALUES(?, ?);';

  SQLCreate_RnQ_AVT : AnsiString =
    'CREATE TABLE IF NOT EXISTS RAVT.avatars('+CRLF+
    ' AVT_HASH BLOB(16) NOT NULL ON CONFLICT FAIL COLLATE BINARY,'+CRLF+
    ' AVT_TYPE NUMBER(1) NOT NULL ON CONFLICT FAIL COLLATE BINARY,'+CRLF+
    ' data BLOB NOT NULL ON CONFLICT FAIL,'+CRLF+
    ' CONSTRAINT AVT_PK PRIMARY KEY (AVT_HASH, AVT_TYPE COLLATE NOCASE) ON CONFLICT FAIL);';

  SQLInsertAVT : AnsiString = 'INSERT INTO RAVT.avatars VALUES(?, ?, ?);';
const
  AVTTypePic = 0;
  AVTTypeXML = 1;
  AVTTypeXMLPic = 2;
  AVTTypePhoto = 3;

  SQLCreateDBTable : AnsiString =
    'CREATE TABLE IF NOT EXISTS DB ('+CRLF+
    '  UID TEXT UNIQUE PRIMARY KEY,'+CRLF+
    '  DISPLAY TEXT,'+CRLF+
    '  "NICK" TEXT,'+CRLF+
    '  FIRSTNAME TEXT,'+CRLF+
    '  LASTNAME TEXT,'+CRLF+
    '  BIRTHL DATE,'+CRLF+
    '  SENDTRANSL INTEGER(1),'+CRLF+
    '  bdata BLOB);';
  SQLInsertDBrow : AnsiString = 'INSERT INTO DB VALUES(?, ?, ?, ?, ?, ?, ?, ?);';

  SQLCreatePrefTable : AnsiString =
    'CREATE TABLE IF NOT EXISTS Pref ('+CRLF+
    '  key TEXT UNIQUE PRIMARY KEY,'+CRLF+
    '  val_type INTEGER(1),'+CRLF+
    '  val TEXT);';
  SQLInsertPref : AnsiString = 'INSERT INTO Pref VALUES(?, ?, ?);';

  SQLCreateExStsTable : AnsiString =
    'CREATE TABLE IF NOT EXISTS ExStatus ('+CRLF+
    '  id TEXT UNIQUE PRIMARY KEY,'+CRLF+
    '  cap TEXT,'+CRLF+
    '  caption TEXT,'+CRLF+
    '  desc TEXT);';

  SQLInsertExSts : AnsiString = 'INSERT INTO ExStatus VALUES(?, ?, ?, ?);';

{  SQLCreateDBTable =
    'CREATE TABLE IF NOT EXISTS UserBase (' + CRLF +
    '  Idx INTEGER UNIQUE PRIMARY KEY,' + CRLF +
    '  DISPLAY TEXT);';

  SQLCreateDB2IMTable =
    'CREATE TABLE IF NOT EXISTS UserBase2IM (' + CRLF +
    '  Idx INTEGER PRIMARY KEY,' + CRLF +
    '  IMTYPE INTEGER NOT NULL, ' + CRLF +
    '  UID TEXT NOT NULL,' +
    '  UNIQUE(IMTYPE, UID) );';

  SQLCreateOscarDBTable =
    'CREATE TABLE IF NOT EXISTS OscarBase (' + CRLF +
//    '  Idx INTEGER PRIMARY KEY,' + CRLF +
    '  UID TEXT PRIMARY KEY, ' + CRLF +
    '  SSIID INTEGER,    ' + CRLF +
    '  "NICK" TEXT, ' + CRLF +
    '  FIRSTNAME TEXT,' + CRLF +
    '  LASTNAME TEXT, ' + CRLF +
    '  "EMAIL" TEXT,  ' + CRLF +
    '  CITY    TEXT,  ' + CRLF +
    '  "STATE" TEXT,  ' + CRLF +
    '  "ABOUT" TEXT,  ' + CRLF +
    '  "DISPLAY" TEXT,' + CRLF +
    '  "QUERY" TEXT,  ' + CRLF +
    '  "ZIP"   TEXT,  ' + CRLF +
    '  COUNTRY INTEGER,' + CRLF +
    '  BIRTH  DATE,   ' + CRLF +
    '  BIRTHL DATE,   ' + CRLF +
    '  "LANG" INTEGER(3), ' + CRLF +
    '  HOMEPAGE TEXT, ' + CRLF +
    '  CELLULAR TEXT, ' + CRLF +
    '  IP  INTEGER(4),' + CRLF +
    '  AGE NUMBER,    ' + CRLF +
//    '  GMT NUMBER,    ' + CRLF +
    '  GMThalfs NUMBER, ' + CRLF +
    '  GENDER   NUMBER, ' + CRLF +
    '  "GROUP" TEXT,  ' + CRLF +
    '  LASTINFOUPDATE DOUBLE,' + CRLF +
    '  LASTONLINETIME DOUBLE,' + CRLF +
    '  LASTMSGtime    DOUBLE,' + CRLF +
    '  MEMBERSINCE    DOUBLE,' + CRLF +
    '  ONLINESINCE    DOUBLE,' + CRLF +
    '  NOTES TEXT,  ' + CRLF +
    '  DONTDELETE INTEGER(1),' + CRLF +
    '  ASKEDAUTH  INTEGER(1),' + CRLF +
    '  TOQUERY    INTEGER(1),' + CRLF +
    '  SMSABLE    INTEGER(1),' + CRLF +
    '  NODB       INTEGER(1),' + CRLF +
    '  SENDTRANSL INTEGER(1),' + CRLF +
    '  INTEREST1  INTEGER(1), ' + CRLF +
    '  INTEREST2  INTEGER(1), ' + CRLF +
    '  INTEREST3  INTEGER(1), ' + CRLF +
    '  INTEREST4  INTEGER(1), ' + CRLF +
    '  INTERESTS1 text, ' + CRLF +
    '  INTERESTS2 text, ' + CRLF +
    '  INTERESTS3 text, ' + CRLF +
    '  INTERESTS4 text, ' + CRLF +

    '  WORKPAGE  TEXT, ' + CRLF +
    '  WORKSTNT  TEXT, ' + CRLF + // Должность
    '  WORKDEPT  TEXT, ' + CRLF + // Департамент
    '  WORKCOMPANY TEXT,' + CRLF + // Компания
    '  WORKCOUNTRY NUMBER(4),' + CRLF +
    '  WORKZIP   TEXT, ' + CRLF +
    '  WORKADDRESS  TEXT,' + CRLF +
    '  WORKPHONE TEXT, ' + CRLF +
    '  WORKSTATE TEXT, ' + CRLF +
    '  WORKCITY  TEXT, ' + CRLF +

    '  ImpString TEXT, ' + CRLF +
    '  Authorized INTEGER(1),' + CRLF +
    '  ICONSHOW   INTEGER(1),' + CRLF +
    '  ICONMD5 BINARY(16),   ' + CRLF +
    '  MARSTATUS INTEGER);';
//CREATE UNIQUE INDEX UID_IM ON UserBase(IMTYPE,UID)
}
  SQLCreateHistTable : AnsiString =
   'CREATE TABLE IF NOT EXISTS "Conversations" ('
        + '"Chat" TEXT NOT NULL,'
        + '"When" DATETIME NOT NULL,'
        + '"Who" TEXT NOT NULL,'
        + '"Kind" INTEGER NOT NULL,'
        + '"Text" TEXT,'
        + '"Binary" BLOB,'
        + '"Flags" INTEGER DEFAULT 0,'
        + '"Out" INTEGER,'
        + '"WID" GUID,'
        + '"MsgID" INTEGER);' + CRLF
    +'CREATE INDEX "timeindex" ON "Conversations" ("Chat", "When");'
//    +'CREATE INDEX "chatindex" ON "Conversations" ("Chat");'
//   ', PRIMARY KEY (MSG_TIME, FROM_UID, TO_UID, ISSEND) '+
//   ' CREATE INDEX MSG_UID ON History(FROM_UID, TO_UID)'
  ;
{
  SQLInsertHistory =
   'INSERT INTO History (' +
   ' MSG_TIME, ISSEND, IMTYPE, FROM_UID, TO_UID, kind, flags, info, msg) ' +
   ' VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)';
}
  SQLInsertHistory =
   'INSERT INTO Conversations (' +
   ' "Chat", "when", "who", "kind", "flags", "Binary", "Text", "out") ' +
   ' VALUES(?, ?, ?, ?, ?, ?, ?, ?)';

  SQLDeleteHistoryWith =
   'DELETE History WHERE FROM_UID = "%s" or TO_UID = "%s"';
  SQLSelectHistoryWith =
   'SELECT MSG_TIME, ISSEND, IMTYPE, FROM_UID, TO_UID, kind, flags, info, msg '+
    ' FROM History WHERE FROM_UID = "%s" or TO_UID = "%s" ORDER BY MSG_TIME';

  SQLInsertContact =
//    'INSERT INTO UserBase (IMTYPE, UID) VALUES(%d, ''%s'')';
    'INSERT INTO OscarBase (UID) VALUES(''%s'')';
  SQLUpdateOscarCnt =
//    'UPDATE UserBase set "%s" = ''%s'' WHERE idx = %d';
//    'UPDATE OscarBase set ? = ? WHERE rowid = ?;';
    'UPDATE OscarBase set "%s" = ? WHERE rowid = ?;';
  SQLUpdateOscarCnt2 =
    'UPDATE OscarBase set "%s" = ''%s'' WHERE rowid = %d';
  SQLUpdateOscarCnt3 =
    'UPDATE OscarBase set "%s" = ''%d'' WHERE rowid = %d';
  SQLUpdateOscarCnt10 =
//    'UPDATE UserBase set "%s" = ''%s'' WHERE idx = %d';
//    'UPDATE OscarBase set ? = ? WHERE rowid = ?;';
    'UPDATE OscarBase set %s WHERE rowid = ?;';


implementation

end.
