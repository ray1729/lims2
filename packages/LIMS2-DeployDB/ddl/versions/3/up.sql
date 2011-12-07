CREATE TABLE changesets (
       changeset_id     SERIAL PRIMARY KEY,
       user_id          INTEGER NOT NULL REFERENCES users(user_id),
       created_date     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON changesets TO :ro_role;
GRANT SELECT, UPDATE, INSERT, DELETE ON changesets TO :rw_role;
GRANT USAGE ON changesets_changeset_id_seq TO :rw_role;

CREATE TABLE changeset_entries (
       changeset_id            INTEGER NOT NULL REFERENCES changesets(changeset_id),
       rank                    INTEGER NOT NULL,
       action                  TEXT NOT NULL CHECK (action IN ( 'create', 'update', 'delete' )),
       uri                     TEXT NOT NULL,
       data                    TEXT NOT NULL DEFAULT '{}',
       PRIMARY KEY(changeset_id, rank)                               
);
GRANT SELECT ON changeset_entries TO :ro_role;
GRANT SELECT, UPDATE, INSERT, DELETE ON changeset_entries TO :rw_role;
