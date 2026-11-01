-- Run only in a disposable schema. This removes the two candidate indexes before measurement.
SET TIMING ON;
BEGIN
 FOR x IN (SELECT index_name FROM USER_INDEXES WHERE index_name IN('IX_EVENTS_START_STATUS','IX_REG_USER_STATUS')) LOOP
  EXECUTE IMMEDIATE 'DROP INDEX '||DBMS_ASSERT.SIMPLE_SQL_NAME(x.index_name);
 END LOOP;
 DBMS_STATS.GATHER_TABLE_STATS(USER,'EVENTS');DBMS_STATS.GATHER_TABLE_STATS(USER,'EVENT_REGISTRATIONS');
END;
/
SPOOL campusconnect_before_indexes.txt
EXPLAIN PLAN SET STATEMENT_ID='CC_EVENT_DATE_BEFORE' FOR
 SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'CC_EVENT_DATE_BEFORE','BASIC +PREDICATE +COST'));
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SPOOL OFF
