# Assignment requirement mapping

## Practical 10 — Oracle PL/SQL

| Requirement | Implementation |
|---|---|
| Insert/update/delete procedures | `database/04_procedures_functions.sql`: `INSERT_CLUB`, `UPDATE_CLUB`, `DELETE_CLUB`; `DELETE_CLUB` removes dependent registrations, memberships, club announcements, and events in foreign-key order. Event audit rows are retained. |
| Database users and roles | `database/07_security_roles.sql`; placeholder secrets; guest/app/developer roles, no DBA grant to app. |
| Login-data procedure | `CHECK_LOGIN_HASH`; compares a precomputed hash for the exercise. Production bcrypt comparison is in `server/src/routes/auth.js`, never plaintext storage. |
| Explicit cursor | `LIST_CLUBS` uses OPEN/FETCH/EXIT WHEN/CLOSE without limit. |
| Bounded cursor | `LIST_CLUBS_BATCH` uses Oracle `BULK COLLECT ... LIMIT`. Oracle has no MySQL cursor `LIMIT` syntax. |
| Pagination without/with filter | `CAMPUS_SEARCH.PAGE_EVENTS` and `FILTER_EVENTS`; ref cursor, validated page size and stable event/time key ordering. API event route calls FILTER_EVENTS. |
| SUM without grouping | `TOTAL_PUBLISHED_CAPACITY`. |
| SUM with grouping | `V_CAPACITY_BY_CLUB`; GROUP BY yields multiple rows, so a view is the appropriate relational result. |
| BEFORE integrity trigger | `TRG_EVENTS_VALIDATE`: future start on creation/start update; capacity cannot be lowered below registered rows. |
| Uppercase conversion | `TRG_CLUBS_NORMALIZE`, a compound trigger with a BEFORE EACH ROW section. Statement-level sections cannot access :NEW/:OLD. |
| AFTER audit trigger | `TRG_EVENTS_AUDIT`: old/new JSON values and actor on INSERT/UPDATE/DELETE; same transaction, no recursive audit. |
| Monday restriction | `IS_EVENTS_LOCKED` and `TRG_EVENTS_TIME_BLOCK`, Monday 14:00–16:00 Asia/Kolkata. Demo includes both boundaries and helper tests. |
| Executable demonstrations | `database/06_demonstrations.sql`, `10_verify_objects.sql`; use SQLcl/SQL*Plus. |

## Practical 11 — SQL, views, indexes and XML

| Requirement | Implementation |
|---|---|
| Display all table rows | SQL Q1 in `database/08_query_examples.sql`; DBMS Lab Q1 displays clubs. |
| Related inserts / referential integrity | API CRUD insertion binds and FK constraints; event registration uses `REGISTER_FOR_EVENT` row lock. |
| COUNT/SUM/AVG/MIN/MAX | SQL Q3 and DBMS Lab aggregate dropdown. |
| Conditional queries | `/api/lab/conditional/:table`; fixed table/column/operator allowlists, values bound. |
| INNER/LEFT/RIGHT/FULL OUTER joins | `/api/lab/join`; fixed table pairs and fixed join keywords, plus SQL examples Q5. |
| Subquery | `q6-subquery` and SQL Q6. |
| Correlated subquery | `q7-correlated` and SQL Q7; inner query references outer `c.club_id`. |
| Update/display | CRUD panel and SQL Q8. |
| Useful indexes and timing | `database/02_indexes.sql`, `09_benchmark.sql`, `09a_benchmark_before.sql`, `09b_benchmark_after.sql`, `DBMS_XPLAN`; collect actual timings locally. |
| View + stored procedure + validation trigger | `V_CLUB_EVENT`, `TRG_V_CLUB_EVENT_INSERT`, and insert procedures. The INSTEAD OF trigger maps a non-key-preserved join view to EVENTS; base table validation still fires. |
| XML for Query 1, 3 and 4 | `/api/lab/scenario/:name?format=xml`; only Q1/Q3/Q4 have XML. XML is serialized from fetched Oracle data, escapes &, <, >, quotes and apostrophes, and marks null fields with `xsi:nil`. |
| Dashboard statistics | `/api/dashboard` scalar counts from all requested major tables and event-status counts; no fixed metrics. |

## Running and interpreting the index comparison

Run `database/09_benchmark.sql` in SQLcl/SQL*Plus with `SET TIMING ON`, representative row volume and fresh stats. Compare repeated medians and the DBMS_XPLAN access path before and after `02_indexes.sql` on a disposable schema. Preserve outputs and record the data volume. The project intentionally includes no fabricated benchmark values. Optimizer plans may choose a full scan when it costs less.

For a fixed before/after sequence, execute `09a_benchmark_before.sql`, followed by `09b_benchmark_after.sql`, in the same disposable schema. The first drops only the two candidate indexes; the second creates them. They spool separate observed outputs. Review every measurement; do not generalize a result from the small demo seed.
