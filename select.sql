SELECT datetime("MSG_TIME"), "ISSEND", "IMTYPE", "FROM_UID", "TO_UID", "kind", "flags", "info", "msg" FROM "History" h
where  h.from_UID = '219465643' or h.to_UID = '219465643'
 order by 1