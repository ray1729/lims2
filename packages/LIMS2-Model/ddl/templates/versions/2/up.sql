--
-- Define tables for storing general plate and well data, tree paths
-- (well relationships), and design and pcs well data.
--

--
-- Data applicable to all plates
--
CREATE TABLE plate_types (
       plate_type      TEXT PRIMARY KEY CHECK (plate_type <> ''),
       plate_type_desc TEXT NOT NULL DEFAULT ''
);

GRANT SELECT ON plate_types TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON plate_types TO "[% rw_role %]";

CREATE TABLE plates (
       plate_id       SERIAL PRIMARY KEY,
       plate_name     TEXT NOT NULL UNIQUE CHECK ( plate_name <> '' ),
       plate_type     TEXT NOT NULL REFERENCES plate_types(plate_type),
       plate_desc     TEXT NOT NULL DEFAULT '',
       created_by     INTEGER NOT NULL REFERENCES users(user_id),
       created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

GRANT SELECT ON plates TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON plates TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE plates_plate_id_seq TO "[% rw_role %]";

CREATE TABLE plate_comments (
       plate_comment_id     SERIAL PRIMARY KEY,
       plate_id             INTEGER NOT NULL REFERENCES plates(plate_id),
       plate_comment        TEXT NOT NULL CHECK (plate_comment <> ''),
       created_by           INTEGER NOT NULL REFERENCES users(user_id),
       created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

GRANT SELECT ON plate_comments TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON plate_comments TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE plate_comments_plate_comment_id_seq TO "[% rw_role %]";

--
-- Data applicable to all wells
--
CREATE TABLE wells (
       well_id          SERIAL PRIMARY KEY,
       plate_id         INTEGER NOT NULL REFERENCES plates(plate_id),
       well_name        CHARACTER(3) NOT NULL CHECK (well_name ~ '^[A-O](0[1-9]|1[0-9]|2[0-4])$'),
       created_by       INTEGER NOT NULL REFERENCES users(user_id),
       created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       assay_pending    TIMESTAMP,
       assay_complete   TIMESTAMP,
       accepted         BOOLEAN NOT NULL DEFAULT FALSE,
       UNIQUE (plate_id, well_name)
);

GRANT SELECT ON wells TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON wells TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE wells_well_id_seq TO "[% rw_role %]";

CREATE TABLE well_accepted_override (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       accepted            BOOLEAN NOT NULL,
       created_by          INTEGER NOT NULL REFERENCES users(user_id),
       created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON well_accepted_override TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_accepted_override TO "[% rw_role %]";

CREATE TABLE tree_paths (
       ancestor         INTEGER NOT NULL REFERENCES wells(well_id),
       descendant       INTEGER NOT NULL REFERENCES wells(well_id),
       path_length      INTEGER NOT NULL,
       PRIMARY KEY( ancestor, descendant )
);

CREATE INDEX ON tree_paths(ancestor);
CREATE INDEX ON tree_paths(descendant);

GRANT SELECT ON tree_paths TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON tree_paths TO "[% rw_role %]";

CREATE TABLE assay_result (
       assay  TEXT NOT NULL,
       result TEXT NOT NULL,
       PRIMARY KEY (assay, result)
);
GRANT SELECT ON assay_result TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON assay_result TO "[% rw_role %]";

CREATE TABLE well_assay_results (
       well_id     INTEGER NOT NULL REFERENCES wells(well_id),
       assay       TEXT NOT NULL,
       result      TEXT NOT NULL,
       created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       created_by  INTEGER NOT NULL REFERENCES users(user_id),
       PRIMARY KEY (well_id, assay ),
       FOREIGN KEY (assay, result) REFERENCES assay_result(assay, result)
);
GRANT SELECT ON well_assay_results TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_assay_results TO "[% rw_role %]";

--
-- Data specific to design wells
--

CREATE TABLE design_well_design (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       design_id           INTEGER NOT NULL REFERENCES designs(design_id)
);
GRANT SELECT ON design_well_design TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_well_design TO "[% rw_role %]";

CREATE INDEX ON design_well_design(design_id);

CREATE TABLE design_well_bac (
       well_id             INTEGER NOT NULL REFERENCES wells(well_id),
       bac_plate           TEXT NOT NULL,
       bac_library         TEXT NOT NULL,
       bac_name            TEXT NOT NULL,
       UNIQUE( well_id, bac_plate),
       FOREIGN KEY(bac_name, bac_library) REFERENCES bac_clones(bac_name, bac_library)
);
GRANT SELECT ON design_well_bac TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_well_bac TO "[% rw_role %]";

