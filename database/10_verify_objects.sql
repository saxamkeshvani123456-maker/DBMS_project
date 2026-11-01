-- Run as the schema owner after all DDL. Empty USER_ERRORS output means no stored-object compile errors.
SELECT name,type,line,position,text FROM USER_ERRORS ORDER BY name,sequence;
SELECT object_name,object_type,status FROM USER_OBJECTS WHERE object_type IN('PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY','TRIGGER','VIEW') ORDER BY object_type,object_name;
SELECT table_name FROM USER_TABLES WHERE table_name IN('USERS','CLUBS','CLUB_MEMBERSHIPS','CLUB_REQUESTS','EVENTS','EVENT_REGISTRATIONS','ANNOUNCEMENTS','LOST_FOUND_ITEMS','ACADEMIC_RESOURCES','APPLICATION_AUDIT_LOG','ACTIVITY_LOGS') ORDER BY table_name;
