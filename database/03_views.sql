CREATE OR REPLACE VIEW V_EVENT_SUMMARY AS
 SELECT e.event_id,e.title,e.venue,e.start_datetime,e.end_datetime,e.capacity,e.event_status,
        e.club_id,c.club_name,COUNT(CASE WHEN r.registration_status='REGISTERED' THEN 1 END) registered_count
 FROM EVENTS e JOIN CLUBS c ON c.club_id=e.club_id LEFT JOIN EVENT_REGISTRATIONS r ON r.event_id=e.event_id
 GROUP BY e.event_id,e.title,e.venue,e.start_datetime,e.end_datetime,e.capacity,e.event_status,e.club_id,c.club_name;
CREATE OR REPLACE VIEW V_CLUB_CAPACITY AS
 SELECT c.club_id,c.club_name,NVL(SUM(CASE WHEN e.event_status='PUBLISHED' THEN e.capacity END),0) total_capacity
 FROM CLUBS c LEFT JOIN EVENTS e ON e.club_id=c.club_id GROUP BY c.club_id,c.club_name;
CREATE OR REPLACE VIEW V_ACTIVE_MEMBERS AS
 SELECT m.membership_id,u.user_id,u.full_name,u.email,c.club_id,c.club_name,m.membership_role,m.joined_at
 FROM CLUB_MEMBERSHIPS m JOIN USERS u ON u.user_id=m.user_id JOIN CLUBS c ON c.club_id=m.club_id
 WHERE m.membership_status='ACTIVE';
