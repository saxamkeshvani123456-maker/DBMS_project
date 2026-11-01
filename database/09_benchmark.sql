-- Repeatable elapsed-time + plan comparison; execute in SQLcl/SQL*Plus on a populated test schema.
-- 1) Before indexes: run schema/views/procedures, but defer 02_indexes.sql; gather stats and capture output.
-- 2) Run the same workload below for >=5 passes, note elapsed times, rows and plan.
-- 3) Create 02_indexes.sql, gather stats again, rerun. Preserve both outputs for the report.
-- Never claim a gain without measurements. Compare median, buffer/row estimates and plan. Indexes may slow DML.
SET TIMING ON;
SET AUTOTRACE OFF;
BEGIN DBMS_STATS.GATHER_TABLE_STATS(USER,'EVENTS'); DBMS_STATS.GATHER_TABLE_STATS(USER,'EVENT_REGISTRATIONS'); END;
/
EXPLAIN PLAN SET STATEMENT_ID='CC_EVENT_DATE' FOR
 SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'CC_EVENT_DATE','BASIC +PREDICATE +COST'));
-- Repeat this select 5+ times; SQLcl's SET TIMING reports observed elapsed time.
SELECT event_id,title,start_datetime FROM EVENTS WHERE event_status='PUBLISHED' AND start_datetime>=SYSTIMESTAMP ORDER BY start_datetime,event_id;
EXPLAIN PLAN SET STATEMENT_ID='CC_STUDENT_REGS' FOR
 SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'CC_STUDENT_REGS','BASIC +PREDICATE +COST'));
SELECT event_id,registration_status FROM EVENT_REGISTRATIONS WHERE user_id=100 AND registration_status='REGISTERED';
