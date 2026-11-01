-- Run after 09a in the same disposable schema. Captures comparable after-index observations.
SET TIMING ON;
BEGIN
 EXECUTE IMMEDIATE 'CREATE INDEX IX_EVENTS_START_STATUS ON EVENTS(event_status,start_datetime,event_id)';
 EXECUTE IMMEDIATE 'CREATE INDEX IX_REG_USER_STATUS ON EVENT_REGISTRATIONS(user_id,registration_status)';
 DBMS_STATS.GATHER_TABLE_STATS(USER,'EVENTS');DBMS_STATS.GATHER_TABLE_STATS(USER,'EVENT_REGISTRATIONS');
EXCEPTION WHEN OTHERS THEN IF SQLCODE=-955 THEN NULL; ELSE RAISE; END IF;
END;
/
SPOOL campusconnect_after_indexes.txt
EXPLAIN PLAN SET STATEMENT_ID='CC_EVENT_DATE_AFTER' FOR
 SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'CC_EVENT_DATE_AFTER','BASIC +PREDICATE +COST'));
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SPOOL OFF
