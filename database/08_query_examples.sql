-- Q1: display all rows from a main table; API XML viewer supports this query.
SELECT club_id,club_name,description,category,created_at FROM CLUBS ORDER BY club_id;
-- Q2: related inserts must preserve FK relationships. Prefer the APIs/procedure; example transaction:
-- INSERT USERS first, then CLUBS, then CLUB_MEMBERSHIPS with the generated IDs; COMMIT only after all succeed.
-- Q3: COUNT/SUM/AVG/MIN/MAX; XML is available for this aggregate result.
SELECT COUNT(*) event_count,NVL(SUM(capacity),0) seats_total,NVL(AVG(capacity),0) avg_capacity,
       MIN(start_datetime) first_event,MAX(start_datetime) last_event FROM EVENTS;
-- Q4: conditional event query; bind event status from the API allowlist. XML is available here.
SELECT event_id,title,venue,start_datetime,event_status FROM EVENTS WHERE event_status='PUBLISHED' ORDER BY start_datetime;
-- Q5: INNER, LEFT, RIGHT and FULL OUTER joins.
SELECT c.club_name,e.title FROM CLUBS c INNER JOIN EVENTS e ON e.club_id=c.club_id;
SELECT c.club_name,e.title FROM CLUBS c LEFT JOIN EVENTS e ON e.club_id=c.club_id;
SELECT c.club_name,e.title FROM CLUBS c RIGHT JOIN EVENTS e ON e.club_id=c.club_id;
SELECT c.club_name,e.title FROM CLUBS c FULL OUTER JOIN EVENTS e ON e.club_id=c.club_id;
-- Q6: subquery across related tables: users registered for a published event.
SELECT u.user_id,u.full_name FROM USERS u WHERE u.user_id IN
 (SELECT r.user_id FROM EVENT_REGISTRATIONS r JOIN EVENTS e ON e.event_id=r.event_id WHERE e.event_status='PUBLISHED');
-- Q7: genuinely correlated query: each club compared with its own event count.
SELECT c.club_id,c.club_name FROM CLUBS c WHERE
 (SELECT COUNT(*) FROM EVENTS e WHERE e.club_id=c.club_id)>0 ORDER BY c.club_name;
-- Q8: update and display updated result (run for an existing club ID).
-- UPDATE CLUBS SET description=:description WHERE club_id=:club_id;
-- SELECT club_id,club_name,description FROM CLUBS WHERE club_id=:club_id;
-- Additional practical examples: conditional aggregation by event status and users per club.
SELECT event_status,COUNT(*) event_count,MIN(capacity) min_capacity,MAX(capacity) max_capacity
FROM EVENTS GROUP BY event_status ORDER BY event_status;
SELECT c.club_name,COUNT(m.user_id) members FROM CLUBS c LEFT JOIN CLUB_MEMBERSHIPS m
 ON m.club_id=c.club_id AND m.membership_status='ACTIVE' GROUP BY c.club_name ORDER BY c.club_name;
