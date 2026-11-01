-- INSERT/UPDATE/DELETE procedures. Delete preserves club history by allowing FK restriction to surface.
CREATE OR REPLACE PROCEDURE INSERT_CLUB(p_name IN VARCHAR2,p_description IN VARCHAR2,p_category IN VARCHAR2,p_id OUT NUMBER) AS
BEGIN
 IF TRIM(p_name) IS NULL THEN RAISE_APPLICATION_ERROR(-20001,'Club name is required'); END IF;
 INSERT INTO CLUBS(club_name,description,category) VALUES(TRIM(p_name),p_description,p_category) RETURNING club_id INTO p_id;
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20002,'Club name already exists'); END;
/
CREATE OR REPLACE PROCEDURE UPDATE_CLUB(p_id IN NUMBER,p_name IN VARCHAR2,p_description IN VARCHAR2,p_category IN VARCHAR2) AS
BEGIN
 IF p_id IS NULL OR TRIM(p_name) IS NULL THEN RAISE_APPLICATION_ERROR(-20003,'Club ID and name are required'); END IF;
 UPDATE CLUBS SET club_name=TRIM(p_name),description=p_description,category=p_category WHERE club_id=p_id;
 IF SQL%ROWCOUNT=0 THEN RAISE_APPLICATION_ERROR(-20004,'Club not found'); END IF;
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20005,'Club name already exists'); END;
/
CREATE OR REPLACE PROCEDURE DELETE_CLUB(p_id IN NUMBER,p_result OUT VARCHAR2) AS
BEGIN DELETE FROM CLUBS WHERE club_id=p_id; IF SQL%ROWCOUNT=0 THEN RAISE_APPLICATION_ERROR(-20006,'Club not found'); END IF; p_result:='Club deleted';
EXCEPTION WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20007,'Club has related history and cannot be deleted'); ELSE RAISE; END IF; END;
/
-- Capacity-safe transactional registration: row lock serializes concurrent capacity checks.
CREATE OR REPLACE PROCEDURE REGISTER_FOR_EVENT(p_event_id IN NUMBER,p_user_id IN NUMBER) AS
 v_capacity NUMBER; v_status VARCHAR2(20); v_start TIMESTAMP WITH TIME ZONE; v_active NUMBER;
BEGIN
 SELECT capacity,event_status,start_datetime INTO v_capacity,v_status,v_start FROM EVENTS WHERE event_id=p_event_id FOR UPDATE;
 IF v_status<>'PUBLISHED' OR v_start<=SYSTIMESTAMP THEN RAISE_APPLICATION_ERROR(-20008,'Event is closed for registration'); END IF;
 SELECT COUNT(*) INTO v_active FROM EVENT_REGISTRATIONS WHERE event_id=p_event_id AND registration_status='REGISTERED';
 IF v_active>=v_capacity THEN RAISE_APPLICATION_ERROR(-20009,'Event is at capacity'); END IF;
 INSERT INTO EVENT_REGISTRATIONS(event_id,user_id) VALUES(p_event_id,p_user_id);
EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20010,'Event not found'); WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20011,'Already registered'); END;
/
-- Assignment login demonstration: compares a precomputed credential hash. Production bcrypt verification is in Node.
CREATE OR REPLACE PROCEDURE CHECK_LOGIN_HASH(p_email IN VARCHAR2,p_hash IN VARCHAR2,p_user_id OUT NUMBER,p_valid OUT NUMBER) AS
BEGIN SELECT user_id,CASE WHEN password_hash=p_hash THEN 1 ELSE 0 END INTO p_user_id,p_valid FROM USERS WHERE email=LOWER(TRIM(p_email));
EXCEPTION WHEN NO_DATA_FOUND THEN p_user_id:=NULL;p_valid:=0; END;
/
-- Admin-only actions use definer-rights routines and do not grant direct USERS.ROLE updates.
CREATE OR REPLACE PROCEDURE REVIEW_CLUB_REQUEST(p_request IN NUMBER,p_admin IN NUMBER,p_decision IN VARCHAR2,p_club OUT NUMBER) AS
 v_req CLUB_REQUESTS%ROWTYPE; v_role USERS.role%TYPE;
BEGIN
 IF p_decision NOT IN ('APPROVED','REJECTED') THEN RAISE_APPLICATION_ERROR(-20012,'Invalid decision'); END IF;
 SELECT role INTO v_role FROM USERS WHERE user_id=p_admin; IF v_role<>'ADMIN' THEN RAISE_APPLICATION_ERROR(-20013,'Administrator required'); END IF;
 SELECT * INTO v_req FROM CLUB_REQUESTS WHERE request_id=p_request AND status='PENDING' FOR UPDATE;
 UPDATE CLUB_REQUESTS SET status=p_decision,reviewed_by=p_admin,reviewed_at=SYSTIMESTAMP WHERE request_id=p_request; p_club:=NULL;
 IF p_decision='APPROVED' THEN
  INSERT INTO CLUBS(club_name,description,category) VALUES(v_req.proposed_name,v_req.description,'STUDENT') RETURNING club_id INTO p_club;
  INSERT INTO CLUB_MEMBERSHIPS(user_id,club_id,membership_role,membership_status) VALUES(v_req.requested_by,p_club,'COORDINATOR','ACTIVE');
  UPDATE USERS SET role='COORDINATOR',updated_at=SYSTIMESTAMP WHERE user_id=v_req.requested_by AND role='STUDENT';
 END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20014,'Admin or pending request not found'); WHEN DUP_VAL_ON_INDEX THEN RAISE_APPLICATION_ERROR(-20015,'Club name already exists'); END;
/
CREATE OR REPLACE PROCEDURE SET_USER_ROLE(p_admin IN NUMBER,p_user IN NUMBER,p_role IN VARCHAR2) AS v_role USERS.role%TYPE;
BEGIN
 IF p_role NOT IN ('STUDENT','COORDINATOR','ADMIN') THEN RAISE_APPLICATION_ERROR(-20016,'Invalid role'); END IF;
 SELECT role INTO v_role FROM USERS WHERE user_id=p_admin; IF v_role<>'ADMIN' THEN RAISE_APPLICATION_ERROR(-20017,'Administrator required'); END IF;
 IF p_user=p_admin AND p_role<>'ADMIN' THEN RAISE_APPLICATION_ERROR(-20018,'Cannot remove your own administrator role'); END IF;
 UPDATE USERS SET role=p_role,updated_at=SYSTIMESTAMP WHERE user_id=p_user; IF SQL%ROWCOUNT=0 THEN RAISE_APPLICATION_ERROR(-20019,'User not found'); END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20020,'Administrator not found'); END;
/
CREATE OR REPLACE PROCEDURE DELETE_EVENT(p_admin IN NUMBER,p_event IN NUMBER,p_result OUT VARCHAR2) AS v_role USERS.role%TYPE;
BEGIN
 SELECT role INTO v_role FROM USERS WHERE user_id=p_admin; IF v_role<>'ADMIN' THEN RAISE_APPLICATION_ERROR(-20025,'Administrator required'); END IF;
 DELETE FROM EVENTS WHERE event_id=p_event; IF SQL%ROWCOUNT=0 THEN RAISE_APPLICATION_ERROR(-20026,'Event not found'); END IF;
 p_result:='Event deleted';
EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20027,'Administrator not found'); WHEN OTHERS THEN IF SQLCODE=-2292 THEN RAISE_APPLICATION_ERROR(-20028,'Event has registration history and cannot be deleted'); ELSE RAISE; END IF; END;
/
-- Explicit cursor with OPEN/FETCH/EXIT/CLOSE, no row limit.
CREATE OR REPLACE PROCEDURE LIST_CLUBS AS CURSOR c IS SELECT club_id,club_name,category FROM CLUBS ORDER BY club_id; v c%ROWTYPE;
BEGIN OPEN c; LOOP FETCH c INTO v; EXIT WHEN c%NOTFOUND; DBMS_OUTPUT.PUT_LINE(v.club_id||' | '||v.club_name||' | '||v.category); END LOOP; CLOSE c;
EXCEPTION WHEN OTHERS THEN IF c%ISOPEN THEN CLOSE c; END IF; RAISE; END;
/
-- Oracle bounded fetch equivalent: BULK COLLECT ... LIMIT.
CREATE OR REPLACE PROCEDURE LIST_CLUBS_BATCH(p_size IN PLS_INTEGER DEFAULT 25) AS
 CURSOR c IS SELECT club_id,club_name FROM CLUBS ORDER BY club_id; TYPE t_rows IS TABLE OF c%ROWTYPE; v_rows t_rows;
BEGIN IF p_size NOT BETWEEN 1 AND 500 THEN RAISE_APPLICATION_ERROR(-20021,'Batch size must be 1..500'); END IF;
 OPEN c; LOOP FETCH c BULK COLLECT INTO v_rows LIMIT p_size; EXIT WHEN v_rows.COUNT=0;
  FOR i IN 1..v_rows.COUNT LOOP DBMS_OUTPUT.PUT_LINE(v_rows(i).club_id||' | '||v_rows(i).club_name); END LOOP;
 END LOOP; CLOSE c; END;
/
-- Pagination ref cursors: stable ordering by start time and ID, bound conditions only.
CREATE OR REPLACE PACKAGE CAMPUS_SEARCH AS
 TYPE t_cursor IS REF CURSOR;
 PROCEDURE PAGE_EVENTS(p_page PLS_INTEGER,p_size PLS_INTEGER,p_rows OUT t_cursor);
 PROCEDURE FILTER_EVENTS(p_page PLS_INTEGER,p_size PLS_INTEGER,p_status VARCHAR2,p_club NUMBER,p_title VARCHAR2,p_from TIMESTAMP WITH TIME ZONE,p_to TIMESTAMP WITH TIME ZONE,p_rows OUT t_cursor);
END CAMPUS_SEARCH;
/
CREATE OR REPLACE PACKAGE BODY CAMPUS_SEARCH AS
 PROCEDURE validate_page(p PLS_INTEGER,s PLS_INTEGER) IS BEGIN IF p<1 OR s<1 OR s>100 THEN RAISE_APPLICATION_ERROR(-20022,'Page >= 1 and page size 1..100 required'); END IF; END;
 PROCEDURE PAGE_EVENTS(p_page PLS_INTEGER,p_size PLS_INTEGER,p_rows OUT t_cursor) IS BEGIN validate_page(p_page,p_size);
  OPEN p_rows FOR SELECT e.event_id,e.title,e.venue,e.start_datetime,e.event_status,c.club_name FROM EVENTS e JOIN CLUBS c ON c.club_id=e.club_id ORDER BY e.start_datetime,e.event_id OFFSET (p_page-1)*p_size ROWS FETCH NEXT p_size ROWS ONLY;
 END;
 PROCEDURE FILTER_EVENTS(p_page PLS_INTEGER,p_size PLS_INTEGER,p_status VARCHAR2,p_club NUMBER,p_title VARCHAR2,p_from TIMESTAMP WITH TIME ZONE,p_to TIMESTAMP WITH TIME ZONE,p_rows OUT t_cursor) IS BEGIN
  validate_page(p_page,p_size); IF p_status IS NOT NULL AND p_status NOT IN('DRAFT','PUBLISHED','CANCELLED','COMPLETED') THEN RAISE_APPLICATION_ERROR(-20023,'Invalid event status'); END IF;
  IF p_from IS NOT NULL AND p_to IS NOT NULL AND p_to<p_from THEN RAISE_APPLICATION_ERROR(-20024,'Invalid date range'); END IF;
  OPEN p_rows FOR SELECT e.event_id,e.title,e.venue,e.start_datetime,e.event_status,c.club_name FROM EVENTS e JOIN CLUBS c ON c.club_id=e.club_id
   WHERE (p_status IS NULL OR e.event_status=p_status) AND (p_club IS NULL OR e.club_id=p_club) AND (p_title IS NULL OR INSTR(UPPER(e.title),UPPER(p_title))>0)
   AND (p_from IS NULL OR e.start_datetime>=p_from) AND (p_to IS NULL OR e.start_datetime<=p_to)
   ORDER BY e.start_datetime,e.event_id OFFSET (p_page-1)*p_size ROWS FETCH NEXT p_size ROWS ONLY;
 END;
END CAMPUS_SEARCH;
/
CREATE OR REPLACE FUNCTION TOTAL_PUBLISHED_CAPACITY RETURN NUMBER AS v NUMBER;
BEGIN SELECT NVL(SUM(capacity),0) INTO v FROM EVENTS WHERE event_status='PUBLISHED'; RETURN v; END;
/
-- Grouped SUM returns rows through a view rather than pretending a scalar function can return a table.
CREATE OR REPLACE VIEW V_CAPACITY_BY_CLUB AS SELECT c.club_id,c.club_name,NVL(SUM(CASE WHEN e.event_status='PUBLISHED' THEN e.capacity END),0) total_capacity
FROM CLUBS c LEFT JOIN EVENTS e ON e.club_id=c.club_id GROUP BY c.club_id,c.club_name;
