CREATE TABLE changesets (
       changeset_id     SERIAL PRIMARY KEY,
       user_id          INTEGER NOT NULL REFERENCES users(user_id),
       created_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON changesets TO :ro_role;
GRANT SELECT, UPDATE, INSERT, DELETE ON changesets TO :rw_role;
GRANT USAGE ON changesets_changeset_id_seq TO :rw_role;

CREATE TABLE changeset_entries (
       changeset_entry_id      SERIAL PRIMARY KEY,
       changeset_id            INTEGER NOT NULL REFERENCES changesets(changeset_id),
       action                  TEXT NOT NULL CHECK (action IN ( 'create', 'update', 'delete' )),
       class                   TEXT NOT NULL,
       keys                    TEXT NOT NULL,
       entity                  TEXT NOT NULL
);
GRANT SELECT ON changeset_entries TO :ro_role;
GRANT SELECT, UPDATE, INSERT, DELETE ON changeset_entries TO :rw_role;
GRANT USAGE ON changeset_entries_changeset_entry_id_seq TO :rw_role;

