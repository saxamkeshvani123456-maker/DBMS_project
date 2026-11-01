-- Candidate indexes for event browsing, club lookups, registrations and dashboards.
CREATE INDEX ix_events_start_status ON EVENTS(event_status,start_datetime,event_id);
CREATE INDEX ix_events_club ON EVENTS(club_id,start_datetime);
CREATE INDEX ix_membership_club_status ON CLUB_MEMBERSHIPS(club_id,membership_status);
CREATE INDEX ix_reg_user_status ON EVENT_REGISTRATIONS(user_id,registration_status);
CREATE INDEX ix_reg_event_status ON EVENT_REGISTRATIONS(event_id,registration_status);
CREATE INDEX ix_announcements_created ON ANNOUNCEMENTS(created_at);
CREATE INDEX ix_lost_status_date ON LOST_FOUND_ITEMS(item_status,date_reported);
CREATE INDEX ix_activity_created ON ACTIVITY_LOGS(created_at);
