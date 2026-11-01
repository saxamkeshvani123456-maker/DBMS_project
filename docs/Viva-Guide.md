# CS203 viva guide

- **Keys and relationships:** A primary key identifies a row; an FK references another relation. Membership and event registration tables model many-to-many relationships and enforce one row per pair with composite unique constraints.
- **Normalization:** 1NF stores atomic values. 2NF removes partial dependency on part of a composite key. 3NF removes transitive dependencies among non-key fields. Keeping `club_name` in CLUBS avoids repeating it in every membership.
- **INNER vs outer joins:** INNER returns matching pairs. LEFT retains every left row, RIGHT every right row, FULL retains unmatched rows on both sides with null extension.
- **Subquery vs correlated subquery:** An ordinary subquery can be evaluated independently. A correlated subquery refers to an outer row; the club event count references `c.club_id`.
- **Aggregate/grouping:** COUNT/SUM/AVG/MIN/MAX reduce selected rows. GROUP BY returns one aggregate row per group. A view/ref cursor is appropriate when several grouped rows must be returned.
- **Index:** A B-tree can avoid scanning all rows for selective predicates or ordered lookups. It adds storage and write cost; actual plans and timings decide whether it helps.
- **Procedure/function:** A procedure performs named work and may use OUT parameters. A scalar function returns one value. A grouped result is a relation, so this project returns it through a view/query rather than a fake scalar.
- **Cursor:** An explicit cursor controls OPEN/FETCH/EXIT/CLOSE. Oracle batch fetching uses `BULK COLLECT ... LIMIT` to bound memory and round trips.
- **Trigger:** A row trigger sees :NEW/:OLD; a statement trigger does not. Compound trigger sections combine statement and row timing. The audit trigger records old/new event facts within the same transaction.
- **View:** A view is a stored query, not a copied table. A join/aggregate view may be non-key-preserved and not directly updateable; INSTEAD OF triggers route a view DML operation to base tables.
- **Transaction:** COMMIT makes a unit durable; ROLLBACK undoes it. Audit entries are transactional with the event operation. The registration procedure locks its event row so concurrent callers cannot exceed capacity.
- **Security:** Bcrypt is deliberately slow password hashing; JWT authenticates API calls. SQL identifiers cannot be bind values, so the lab maps selected dropdown values to server allowlists and binds all data values.
- **XML:** Text nodes must escape XML metacharacters. Null is distinct from empty string; outputs mark null explicitly with `xsi:nil`.

## Demo credentials

Seeded addresses and the locally configured password are printed by `npm --workspace server run seed`. Default is `CampusDemo!2026`; change it before seeding outside a disposable demo environment. Never deploy the seed password or `.env` secrets.
