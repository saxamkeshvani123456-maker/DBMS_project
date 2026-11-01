-- Two business integrity checks beyond simple CHECK constraints.
CREATE OR REPLACE TRIGGER TRG_EVENTS_VALIDATE BEFORE INSERT OR UPDATE ON EVENTS FOR EACH ROW
DECLARE v_count NUMBER;
BEGIN
 IF INSERTING OR UPDATING('START_DATETIME') THEN
  IF :NEW.start_datetime<=SYSTIMESTAMP THEN RAISE_APPLICATION_ERROR(-20030,'Event start must be in the future'); END IF;
 END IF;
 IF UPDATING('CAPACITY') AND :NEW.capacity<:OLD.capacity THEN
  SELECT COUNT(*) INTO v_count FROM EVENT_REGISTRATIONS WHERE event_id=:OLD.event_id AND registration_status='REGISTERED';
  IF :NEW.capacity<v_count THEN RAISE_APPLICATION_ERROR(-20031,'Capacity cannot be below active registrations'); END IF;
 END IF;
END;
/
-- Oracle statement triggers cannot reference :NEW or :OLD. Compound trigger includes a row section
-- for the actual normalization and statement sections for statement-wide lifecycle.
CREATE OR REPLACE TRIGGER TRG_CLUBS_NORMALIZE FOR INSERT OR UPDATE OF club_name ON CLUBS COMPOUND TRIGGER
 BEFORE STATEMENT IS BEGIN NULL; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN :NEW.club_name:=UPPER(TRIM(:NEW.club_name)); END BEFORE EACH ROW;
 AFTER STATEMENT IS BEGIN NULL; END AFTER STATEMENT;
END;
/
CREATE OR REPLACE TRIGGER TRG_EVENTS_AUDIT AFTER INSERT OR UPDATE OR DELETE ON EVENTS FOR EACH ROW
DECLARE v_actor VARCHAR2(128):=NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),SYS_CONTEXT('USERENV','SESSION_USER'));
BEGIN
 IF INSERTING THEN
  INSERT INTO APPLICATION_AUDIT_LOG(table_name,record_id,operation_type,changed_by,new_values)
  VALUES('EVENTS',:NEW.event_id,'INSERT',v_actor,JSON_OBJECT('title' VALUE :NEW.title,'capacity' VALUE :NEW.capacity,'status' VALUE :NEW.event_status RETURNING CLOB));
 ELSIF UPDATING THEN
  INSERT INTO APPLICATION_AUDIT_LOG(table_name,record_id,operation_type,changed_by,old_values,new_values)
  VALUES('EVENTS',:NEW.event_id,'UPDATE',v_actor,JSON_OBJECT('title' VALUE :OLD.title,'capacity' VALUE :OLD.capacity,'status' VALUE :OLD.event_status RETURNING CLOB),JSON_OBJECT('title' VALUE :NEW.title,'capacity' VALUE :NEW.capacity,'status' VALUE :NEW.event_status RETURNING CLOB));
 ELSE
  INSERT INTO APPLICATION_AUDIT_LOG(table_name,record_id,operation_type,changed_by,old_values)
  VALUES('EVENTS',:OLD.event_id,'DELETE',v_actor,JSON_OBJECT('title' VALUE :OLD.title,'capacity' VALUE :OLD.capacity,'status' VALUE :OLD.event_status RETURNING CLOB));
 END IF;
END;
/
-- Assignment time block: Mondays 14:00 inclusive to 16:00 exclusive, Asia/Kolkata.
CREATE OR REPLACE FUNCTION IS_EVENTS_LOCKED(p_time TIMESTAMP WITH TIME ZONE) RETURN NUMBER DETERMINISTIC AS
 v_local TIMESTAMP WITH TIME ZONE:=p_time AT TIME ZONE 'Asia/Kolkata'; v_day VARCHAR2(3); v_hour NUMBER;
BEGIN
 v_day:=TO_CHAR(CAST(v_local AS DATE),'DY','NLS_DATE_LANGUAGE=ENGLISH'); v_hour:=TO_NUMBER(TO_CHAR(CAST(v_local AS DATE),'HH24'));
 IF v_day='MON' AND v_hour>=14 AND v_hour<16 THEN RETURN 1; END IF; RETURN 0;
END;
/
CREATE OR REPLACE TRIGGER TRG_EVENTS_TIME_BLOCK BEFORE INSERT OR UPDATE OR DELETE ON EVENTS
DECLARE v_now TIMESTAMP WITH TIME ZONE:=SYSTIMESTAMP AT TIME ZONE 'Asia/Kolkata';
BEGIN IF IS_EVENTS_LOCKED(v_now)=1 THEN RAISE_APPLICATION_ERROR(-20032,'EVENTS are read-only Mondays 14:00–16:00 Asia/Kolkata'); END IF; END;
/
-- Join view for a view-operation demonstration. Oracle cannot insert into a non-key-preserved join
-- reliably; INSTEAD OF trigger maps the view row to base EVENTS and validates club membership.
CREATE OR REPLACE VIEW V_CLUB_EVENT AS
 SELECT e.event_id,e.club_id,c.club_name,e.created_by,e.title,e.venue,e.start_datetime,e.end_datetime,e.capacity,e.event_status
 FROM EVENTS e JOIN CLUBS c ON c.club_id=e.club_id;
CREATE OR REPLACE TRIGGER TRG_V_CLUB_EVENT_INSERT INSTEAD OF INSERT ON V_CLUB_EVENT FOR EACH ROW
DECLARE v_club NUMBER;
BEGIN
 SELECT club_id INTO v_club FROM CLUBS WHERE club_name=UPPER(TRIM(:NEW.club_name));
 IF :NEW.created_by IS NULL OR :NEW.title IS NULL OR :NEW.capacity<=0 THEN RAISE_APPLICATION_ERROR(-20033,'View insert requires creator, title and positive capacity'); END IF;
 INSERT INTO EVENTS(club_id,created_by,title,venue,start_datetime,end_datetime,capacity,event_status)
 VALUES(v_club,:NEW.created_by,:NEW.title,:NEW.venue,:NEW.start_datetime,:NEW.end_datetime,:NEW.capacity,NVL(:NEW.event_status,'DRAFT'));
EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20034,'Club name does not exist'); END;
/
