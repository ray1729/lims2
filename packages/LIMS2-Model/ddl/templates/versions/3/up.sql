--
-- Data for PCS wells (and other plate types)
--
CREATE TABLE well_cassette (
       well_id        INTEGER PRIMARY KEY REFERENCES wells(well_id),
       cassette       TEXT NOT NULL
);
GRANT SELECT ON well_cassette TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_cassette TO "[% rw_role %]";

CREATE TABLE well_backbone (
       well_id        INTEGER PRIMARY KEY REFERENCES wells(well_id),
       backbone       TEXT NOT NULL
);
GRANT SELECT ON well_backbone TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_backbone TO "[% rw_role %]";

CREATE TABLE well_legacy_qc_test_result (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       qc_test_result_id   INTEGER NOT NULL,
       valid_primers       TEXT NOT NULL DEFAULT '',
       pass_level          TEXT NOT NULL
);
GRANT SELECT ON well_legacy_qc_test_result TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_legacy_qc_test_result TO "[% rw_role %]";

CREATE TABLE well_qc_test_result (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       qc_test_result_id   TEXT NOT NULL, 
       valid_primers       TEXT NOT NULL DEFAULT '',
       pass                BOOLEAN NOT NULL DEFAULT FALSE,
       mixed_reads         BOOLEAN NOT NULL DEFAULT FALSE
);
GRANT SELECT ON well_qc_test_result TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_qc_test_result TO "[% rw_role %]";

CREATE TABLE well_clone_name (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       clone_name          TEXT NOT NULL CHECK( clone_name <> '' )
);
GRANT SELECT ON well_clone_name TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_clone_name TO "[% rw_role %]";
