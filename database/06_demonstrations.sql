SET SERVEROUTPUT ON;
-- Seed/setup fixture should exist before these blocks. Set CLIENT_IDENTIFIER where supported.
BEGIN DBMS_SESSION.SET_IDENTIFIER('PLSQL-DEMO'); END;
/
BEGIN LIST_CLUBS; LIST_CLUBS_BATCH(2); END;
/
DECLARE v_id NUMBER; v_ok NUMBER; v_hash USERS.password_hash%TYPE;
BEGIN SELECT password_hash INTO v_hash FROM USERS WHERE email='aarav.shah@campusconnect.test';
 CHECK_LOGIN_HASH('aarav.shah@campusconnect.test',v_hash,v_id,v_ok); DBMS_OUTPUT.PUT_LINE('Hash match result: '||v_ok); END;
/
DECLARE v_club NUMBER; v_result VARCHAR2(100); BEGIN
 INSERT_CLUB('DEMO PROCEDURE CLUB','Created by INSERT_CLUB','DEMO',v_club);
 UPDATE_CLUB(v_club,'DEMO PROCEDURE CLUB UPDATED','Updated','DEMO');
 DELETE_CLUB(v_club,v_result); DBMS_OUTPUT.PUT_LINE(v_result); ROLLBACK;
END;
/
SELECT TOTAL_PUBLISHED_CAPACITY() AS published_capacity FROM dual;
SELECT * FROM V_CAPACITY_BY_CLUB ORDER BY club_name;
VARIABLE rc REFCURSOR;
BEGIN CAMPUS_SEARCH.PAGE_EVENTS(1,10,:rc); END;
/
PRINT rc;
-- Boundary samples on Monday 2026-10-26 in Asia/Kolkata. Expected 0,1,1,0.
SELECT IS_EVENTS_LOCKED(TO_TIMESTAMP_TZ('2026-10-26 13:59:00 Asia/Kolkata','YYYY-MM-DD HH24:MI:SS TZR')) before_window FROM dual;
SELECT IS_EVENTS_LOCKED(TO_TIMESTAMP_TZ('2026-10-26 14:00:00 Asia/Kolkata','YYYY-MM-DD HH24:MI:SS TZR')) start_window FROM dual;
SELECT IS_EVENTS_LOCKED(TO_TIMESTAMP_TZ('2026-10-26 15:59:00 Asia/Kolkata','YYYY-MM-DD HH24:MI:SS TZR')) during_window FROM dual;
SELECT IS_EVENTS_LOCKED(TO_TIMESTAMP_TZ('2026-10-26 16:00:00 Asia/Kolkata','YYYY-MM-DD HH24:MI:SS TZR')) end_window FROM dual;
-- Expected BEFORE-trigger rejection: past start is not allowed. Run outside Monday restriction window.
DECLARE v_uid NUMBER;v_club NUMBER;BEGIN
 SELECT user_id INTO v_uid FROM USERS WHERE email='aarav.shah@campusconnect.test';SELECT club_id INTO v_club FROM CLUBS WHERE ROWNUM=1;
 BEGIN INSERT INTO EVENTS(club_id,created_by,title,venue,start_datetime,end_datetime,capacity) VALUES(v_club,v_uid,'PAST EVENT TEST','Lab',SYSTIMESTAMP-INTERVAL '1' HOUR,SYSTIMESTAMP+INTERVAL '1' HOUR,2);
 EXCEPTION WHEN OTHERS THEN IF SQLCODE=-20030 THEN DBMS_OUTPUT.PUT_LINE('Future-start integrity rule rejected the row as expected'); ELSE RAISE; END IF; END;
END;
/
-- Capacity and related-table insertion example: event then registration in one transaction.
DECLARE v_uid NUMBER;v_club NUMBER;v_event NUMBER;BEGIN
 SELECT user_id INTO v_uid FROM USERS WHERE email='anaya.mehta@campusconnect.test';SELECT club_id INTO v_club FROM CLUBS WHERE ROWNUM=1;
 INSERT INTO EVENTS(club_id,created_by,title,venue,start_datetime,end_datetime,capacity,event_status)
 VALUES(v_club,v_uid,'CAPACITY TEST EVENT','DBMS Lab',SYSTIMESTAMP+INTERVAL '21' DAY,SYSTIMESTAMP+INTERVAL '21' DAY+INTERVAL '1' HOUR,1,'PUBLISHED') RETURNING event_id INTO v_event;
 REGISTER_FOR_EVENT(v_event,v_uid);
 BEGIN UPDATE EVENTS SET capacity=0 WHERE event_id=v_event;EXCEPTION WHEN OTHERS THEN IF SQLCODE=-20031 THEN DBMS_OUTPUT.PUT_LINE('Capacity integrity rule rejected reduction as expected');ELSE RAISE;END IF;END;
 COMMIT;
END;
/
-- Lowercase club-name input is normalized by the compound trigger.
DECLARE v_id NUMBER; v_name VARCHAR2(120); v_result VARCHAR2(100); BEGIN INSERT_CLUB('mixed Case Demo','Normalization check','DEMO',v_id);
 SELECT club_name INTO v_name FROM CLUBS WHERE club_id=v_id; DBMS_OUTPUT.PUT_LINE('Normalized name: '||v_name); DELETE_CLUB(v_id,v_result); COMMIT; END;
/
-- INSERT through a join view invokes its INSTEAD OF trigger; rollback leaves no demo event behind.
DECLARE v_uid NUMBER;v_name VARCHAR2(120);BEGIN
 SELECT user_id INTO v_uid FROM USERS WHERE email='aarav.shah@campusconnect.test';SELECT club_name INTO v_name FROM CLUBS WHERE ROWNUM=1;
 SAVEPOINT view_demo;
 INSERT INTO V_CLUB_EVENT(club_name,created_by,title,venue,start_datetime,end_datetime,capacity,event_status)
 VALUES(v_name,v_uid,'VIEW INSERT DEMO','DBMS Lab',SYSTIMESTAMP+INTERVAL '22' DAY,SYSTIMESTAMP+INTERVAL '22' DAY+INTERVAL '1' HOUR,4,'DRAFT');
 DBMS_OUTPUT.PUT_LINE('View insert trigger created a base EVENTS row');ROLLBACK TO view_demo;
END;
/
-- Audit demo: creates, changes and deletes a future event; audit records remain after commit.
DECLARE v_uid NUMBER; v_club NUMBER; v_event NUMBER; v_audits NUMBER;
BEGIN
 SELECT user_id INTO v_uid FROM USERS WHERE email='aarav.shah@campusconnect.test';
 SELECT club_id INTO v_club FROM CLUBS WHERE ROWNUM=1;
 INSERT INTO EVENTS(club_id,created_by,title,venue,start_datetime,end_datetime,capacity,event_status)
 VALUES(v_club,v_uid,'AUDIT DEMO EVENT','Lab',SYSTIMESTAMP+INTERVAL '20' DAY,SYSTIMESTAMP+INTERVAL '20' DAY+INTERVAL '1' HOUR,5,'DRAFT') RETURNING event_id INTO v_event;
 UPDATE EVENTS SET title='AUDIT DEMO EVENT UPDATED' WHERE event_id=v_event;
 DELETE FROM EVENTS WHERE event_id=v_event;
 SELECT COUNT(*) INTO v_audits FROM APPLICATION_AUDIT_LOG WHERE table_name='EVENTS' AND record_id=v_event;
 DBMS_OUTPUT.PUT_LINE('Audit rows written for demo event: '||v_audits); COMMIT;
END;
/
-- Time-lock helper gives deterministic boundary assertions. Trigger DML itself is allowed only outside the lock window.
