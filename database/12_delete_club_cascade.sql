-- Run as the CAMPUSCONNECT schema owner in FREEPDB1 using SQL Developer (F5).
-- Replaces DELETE_CLUB so admin deletes also remove dependent membership/event rows.
CREATE OR REPLACE PROCEDURE DELETE_CLUB(p_id IN NUMBER,p_result OUT VARCHAR2) AS
 v_club_id CLUBS.club_id%TYPE;
BEGIN
 BEGIN
  SELECT club_id INTO v_club_id FROM CLUBS WHERE club_id=p_id FOR UPDATE;
 EXCEPTION WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20006,'Club not found'); END;

 DELETE FROM EVENT_REGISTRATIONS WHERE event_id IN (SELECT event_id FROM EVENTS WHERE club_id=v_club_id);
 DELETE FROM CLUB_MEMBERSHIPS WHERE club_id=v_club_id;
 DELETE FROM ANNOUNCEMENTS WHERE club_id=v_club_id;
 DELETE FROM EVENTS WHERE club_id=v_club_id;
 DELETE FROM CLUBS WHERE club_id=v_club_id;
 p_result:='Club and related records deleted';
END;
/
