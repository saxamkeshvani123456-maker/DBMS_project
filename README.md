# CampusConnect — SVNIT CS203 DBMS

CampusConnect is a university community portal built with React/Vite, Express, node-oracledb and Oracle SQL/PL/SQL. Assignment implementations are integrated in `database/` beside the schema; there are no separate assignment folders.

## Start locally

Requirements: Node.js 20+, Oracle Database Free 23ai or Oracle 19c+, SQLcl/SQL*Plus. Create the `CAMPUSCONNECT` schema in a local pluggable database (often `FREEPDB1`).

1. Connect as schema owner and run, in order: `database/01_schema.sql`, `02_indexes.sql`, `03_views.sql`, `04_procedures_functions.sql`, `05_triggers.sql`.
2. Run `server/scripts/seed.js` as the schema owner with Oracle connection variables in `server/.env`. It inserts fictional records and hashes a demo password. By default the demo password is `CampusDemo!2026`; override `SEED_DEMO_PASSWORD` before seeding. Accounts: `aarav.shah@campusconnect.test` (ADMIN), `mira.patel@campusconnect.test` (COORDINATOR), and the other sample addresses in the seed script.
3. Run `database/07_security_roles.sql` as an authorized DBA after replacing `CAMPUSCONNECT` if your owner uses a different name and replacing all placeholder passwords. The script creates a read-only guest, restricted app principal/role and a development principal. DBA privileges are deliberately not granted to the app.
4. Copy `.env.example` to `server/.env`; configure the Oracle app account and a long random `JWT_SECRET`. To load seeds using owner privileges for the one-time local demo, temporarily use owner credentials only in this local environment. For production, seed through a controlled owner session and restore `CAMPUS_APP` credentials.
5. From the repository root: `npm install`, then `npm run dev`. Vite is at `http://localhost:5173`; Express is at `http://localhost:4000`.

## Useful scripts

- `database/06_demonstrations.sql`: procedures, cursor examples, aggregate, pagination and time helper.
- `database/08_query_examples.sql`: joins, subquery, correlated subquery, aggregate and update examples.
- `database/09_benchmark.sql`, `09a_benchmark_before.sql`, `09b_benchmark_after.sql`: repeatable before/after index plans and elapsed-time captures (use a disposable schema).
- `database/10_verify_objects.sql`: checks Oracle compilation errors and expected objects.
- `database/11_reset_demo_data.sql`: deletes CampusConnect application rows while preserving schema objects. It is destructive; run only when you intend to clear the current data.
- `database/12_delete_club_cascade.sql`: replaces `DELETE_CLUB` so an administrator can delete a club and its dependent memberships, events, registrations, and club announcements. Event audit rows are retained.
- `npm test`: backend/client tests; Oracle integration is skipped unless `RUN_ORACLE_TESTS=1` and connection variables are set.

## Resetting the demo data

To remove application data you entered and restore the fictional demo records:

1. In SQL Developer, connect to the `FREEPDB1` PDB using the `CAMPUSCONNECT` schema-owner account. The connection's **Username** must be `CAMPUSCONNECT`; its display name can be anything.
2. Open `database/11_reset_demo_data.sql` and press **F5**. This clears application rows but keeps tables, views, procedures, triggers, and indexes.
3. Temporarily set `ORACLE_USER` and `ORACLE_PASSWORD` in `server/.env` to the schema-owner credentials. From the repository root, run `npm --workspace server run seed`.
4. Restore the `CAMPUS_APP` credentials in `server/.env` before running the app again.

## Allowing club deletion

After the base schema and PL/SQL scripts are installed, open `database/12_delete_club_cascade.sql` in SQL Developer using the `CAMPUSCONNECT` connection to `FREEPDB1`, then press **F5**. This updates the stored `DELETE_CLUB` procedure used by the admin console and DBMS Lab. Deleting a club also deletes its memberships, events, event registrations, and club-specific announcements.

Database SQL has not been run against an Oracle instance in this workspace. Follow the run order and inspect `USER_ERRORS`; do not treat generated SQL as proof of Oracle execution. See [docs/Project-Report.md](docs/Project-Report.md), [docs/Assignment-Mapping.md](docs/Assignment-Mapping.md), and [docs/Viva-Guide.md](docs/Viva-Guide.md).
