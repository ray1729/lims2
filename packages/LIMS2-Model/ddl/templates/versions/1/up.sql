--
-- Initial schema version. Contains tables to store users, roles, gene
-- data, BACS, and designs.
--

--
-- Schema metadata
--
CREATE TABLE schema_versions (
       version      INTEGER NOT NULL,
       deployed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (version, deployed_at)
);
GRANT SELECT ON schema_versions TO "[% ro_role %]", "[% rw_role %]";

--
-- Users and roles
--
CREATE TABLE users (
       user_id   SERIAL PRIMARY KEY,
       user_name TEXT NOT NULL UNIQUE CHECK (user_name <> '')
);

GRANT SELECT ON users TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE users_user_id_seq TO "[% rw_role %]";

CREATE TABLE roles (
       role_id    SERIAL PRIMARY KEY,
       role_name  TEXT NOT NULL UNIQUE CHECK (role_name <> '')
);

GRANT SELECT ON roles TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON roles TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE roles_role_id_seq TO "[% rw_role %]";

CREATE TABLE user_role (
       user_id INTEGER NOT NULL REFERENCES users(user_id),
       role_id INTEGER NOT NULL REFERENCES roles(role_id),
       PRIMARY KEY (user_id, role_id)
);

GRANT SELECT ON user_role TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON user_role TO "[% rw_role %]";

--
-- Gene data
--

CREATE TABLE mgi_gene_data (
       mgi_accession_id    TEXT PRIMARY KEY,
       marker_type         TEXT,
       marker_symbol       TEXT,
       marker_name         TEXT,
       representative_genome_id        TEXT,
       representative_genome_chr       TEXT,
       representative_genome_start     INTEGER,
       representative_genome_end       INTEGER,
       representative_genome_strand    INTEGER CHECK (representative_genome_strand IS NULL OR representative_genome_strand IN (1,-1)),
       representative_genome_build     TEXT,
       entrez_gene_id                  TEXT,
       ncbi_gene_chromosome            TEXT,
       ncbi_gene_start                 INTEGER,
       ncbi_gene_end                   INTEGER,
       ncbi_gene_strand                INTEGER CHECK (ncbi_gene_strand IS NULL OR ncbi_gene_strand IN (1,-1)),
       unists_gene_chromosome          TEXT,
       unists_gene_start               INTEGER,
       unists_gene_end                 INTEGER,
       mgi_qtl_gene_chromosome         TEXT,
       mgi_qtl_gene_start              INTEGER,
       mgi_qtl_gene_end                INTEGER,
       mirbase_gene_id                 TEXT,
       mirbase_gene_chromosome         TEXT,
       mirbase_gene_start              INTEGER,
       mirbase_gene_end                INTEGER,
       mirbase_gene_strand             INTEGER CHECK (mirbase_gene_strand IS NULL OR mirbase_gene_strand IN (1,-1)),     
       roopenian_sts_gene_start        INTEGER,
       roopenian_sts_gene_end          INTEGER
);
GRANT SELECT ON mgi_gene_data TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_gene_data TO "[% rw_role %]";

CREATE TABLE ensembl_gene_data (
       ensembl_gene_id         TEXT PRIMARY KEY,
       ensembl_gene_chromosome TEXT NOT NULL,
       ensembl_gene_start      INTEGER NOT NULL,
       ensembl_gene_end        INTEGER NOT NULL,
       ensembl_gene_strand     INTEGER NOT NULL CHECK (ensembl_gene_strand IN (1,-1)), 
       sp                      BOOLEAN NOT NULL,
       tm                      BOOLEAN NOT NULL
);       
GRANT SELECT ON ensembl_gene_data TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON ensembl_gene_data TO "[% rw_role %]";

CREATE TABLE vega_gene_data (
       vega_gene_id         TEXT PRIMARY KEY,
       vega_gene_chromosome TEXT NOT NULL,
       vega_gene_start      INTEGER NOT NULL,
       vega_gene_end        INTEGER NOT NULL,
       vega_gene_strand     INTEGER NOT NULL CHECK (vega_gene_strand IN (1,-1))
);
GRANT SELECT ON vega_gene_data TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON vega_gene_data TO "[% rw_role %]";

CREATE TABLE mgi_ensembl_gene_map (
       mgi_accession_id           TEXT NOT NULL REFERENCES mgi_gene_data(mgi_accession_id),
       ensembl_gene_id            TEXT NOT NULL REFERENCES ensembl_gene_data(ensembl_gene_id),
       PRIMARY KEY(mgi_accession_id,ensembl_gene_id)
);
GRANT SELECT ON mgi_ensembl_gene_map TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_ensembl_gene_map TO "[% rw_role %]";

CREATE INDEX ON mgi_ensembl_gene_map(mgi_accession_id);
CREATE INDEX ON mgi_ensembl_gene_map(ensembl_gene_id);

CREATE TABLE mgi_vega_gene_map (
       mgi_accession_id           TEXT NOT NULL REFERENCES mgi_gene_data(mgi_accession_id),
       vega_gene_id               TEXT NOT NULL REFERENCES vega_gene_data(vega_gene_id),
       PRIMARY KEY(mgi_accession_id,vega_gene_id)
);
GRANT SELECT ON mgi_vega_gene_map TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_vega_gene_map TO "[% rw_role %]";

CREATE INDEX ON mgi_vega_gene_map(mgi_accession_id);
CREATE INDEX ON mgi_vega_gene_map(vega_gene_id);

CREATE TABLE genes (
       gene_id       SERIAL PRIMARY KEY
);
GRANT SELECT ON genes TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON genes TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE genes_gene_id_seq TO "[% rw_role %]";

CREATE TABLE mgi_gene_map (
       gene_id          INTEGER NOT NULL REFERENCES genes(gene_id),
       mgi_accession_id TEXT NOT NULL,
       PRIMARY KEY(gene_id, mgi_accession_id)
);
GRANT SELECT ON mgi_gene_map TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_gene_map TO "[% rw_role %]";

CREATE INDEX ON mgi_gene_map(gene_id);
CREATE INDEX ON mgi_gene_map(mgi_accession_id);

CREATE TABLE gene_comments (
       gene_comment_id     SERIAL PRIMARY KEY,
       gene_id             INTEGER NOT NULL REFERENCES genes(gene_id),
       gene_comment        TEXT NOT NULL,
       is_public           BOOLEAN NOT NULL DEFAULT FALSE,
       created_by          INTEGER NOT NULL REFERENCES users(user_id),
       created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON gene_comments TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON gene_comments TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE gene_comments_gene_comment_id_seq TO "[% rw_role %]";

--
-- Constrained vocabulary for assemblies and chromosomes
--
CREATE TABLE assemblies (
       assembly         TEXT PRIMARY KEY
);
GRANT SELECT ON assemblies TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON assemblies TO "[% rw_role %]";

CREATE TABLE chromosomes (
       chromosome  TEXT PRIMARY KEY
);
GRANT SELECT ON chromosomes TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON chromosomes TO "[% rw_role %]";

--
-- BAC data
--

CREATE TABLE bac_libraries (
       bac_library    TEXT PRIMARY KEY
);
GRANT SELECT ON bac_libraries TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_libraries TO "[% rw_role %]";

CREATE TABLE bac_clones (
       bac_name         TEXT NOT NULL,
       bac_library      TEXT NOT NULL REFERENCES bac_libraries(bac_library),
       PRIMARY KEY (bac_name, bac_library)
);
GRANT SELECT ON bac_clones TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_clones TO "[% rw_role %]";

CREATE TABLE bac_clone_loci (
       bac_name         TEXT NOT NULL,
       bac_library      TEXT NOT NULL,
       assembly         TEXT NOT NULL REFERENCES assemblies(assembly),
       chr_name         TEXT NOT NULL REFERENCES chromosomes(chromosome),
       chr_start        INTEGER NOT NULL,
       chr_end          INTEGER NOT NULL,
       PRIMARY KEY(bac_name, bac_library, assembly),
       FOREIGN KEY(bac_name, bac_library) REFERENCES bac_clones(bac_name, bac_library),
       CHECK (chr_end > chr_start )
);
GRANT SELECT ON bac_clone_loci TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_clone_loci TO "[% rw_role %]";

--
-- Design data
--

CREATE TABLE design_types (
       design_type        TEXT PRIMARY KEY
);
GRANT SELECT ON design_types TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_types TO "[% rw_role %]";

CREATE TABLE designs (
       design_id                INTEGER PRIMARY KEY,
       design_name              TEXT,
       created_by               INTEGER NOT NULL REFERENCES users(user_id),
       created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       design_type              TEXT NOT NULL REFERENCES design_types(design_type),
       phase                    INTEGER NOT NULL,
       validated_by_annotation  TEXT NOT NULL CHECK (validated_by_annotation IN ( 'yes', 'no', 'maybe', 'not done' )),
       targeted_transcript      TEXT NOT NULL
);
GRANT SELECT ON designs TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON designs TO "[% rw_role %]";

CREATE INDEX ON designs(targeted_transcript);

CREATE TABLE design_oligo_types (
       design_oligo_type TEXT PRIMARY KEY
);

GRANT SELECT ON design_oligo_types TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligo_types TO "[% rw_role %]";

CREATE TABLE design_oligos (
       design_id         INTEGER NOT NULL REFERENCES designs(design_id),
       design_oligo_type TEXT NOT NULL REFERENCES design_oligo_types(design_oligo_type),
       design_oligo_seq  TEXT NOT NULL,
       PRIMARY KEY(design_id, design_oligo_type)
);

GRANT SELECT ON design_oligos TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligos TO "[% rw_role %]";

CREATE TABLE design_oligo_loci (
       design_id         INTEGER NOT NULL,
       design_oligo_type TEXT NOT NULL,
       assembly          TEXT NOT NULL REFERENCES assemblies(assembly),
       chr_name          TEXT NOT NULL REFERENCES chromosomes(chromosome),
       chr_start         INTEGER NOT NULL,
       chr_end           INTEGER NOT NULL,
       chr_strand        INTEGER NOT NULL CHECK (chr_strand IN (1, -1)),
       PRIMARY KEY (design_id, design_oligo_type, assembly),
       FOREIGN KEY (design_id, design_oligo_type) REFERENCES design_oligos(design_id, design_oligo_type),
       CHECK ( chr_start <= chr_end )
);

GRANT SELECT ON design_oligo_loci TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligo_loci TO "[% rw_role %]";

CREATE TABLE design_comment_categories (
       design_comment_category_id      SERIAL PRIMARY KEY,
       design_comment_category         TEXT NOT NULL UNIQUE
);
GRANT SELECT ON design_comment_categories TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_comment_categories TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE design_comment_categories_design_comment_category_id_seq TO "[% rw_role %]";

CREATE TABLE design_comments (
       design_comment_id          SERIAL PRIMARY KEY,
       design_comment_category_id INTEGER NOT NULL REFERENCES design_comment_categories(design_comment_category_id),
       design_id                  INTEGER NOT NULL REFERENCES designs(design_id),
       design_comment             TEXT NOT NULL DEFAULT '',
       is_public                  BOOLEAN NOT NULL DEFAULT FALSE,
       created_by                 INTEGER NOT NULL REFERENCES users(user_id),
       created_at                 TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON design_comments TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON design_comments TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE design_comments_design_comment_id_seq TO "[% rw_role %]";

CREATE TABLE genotyping_primer_types (
       genotyping_primer_type TEXT PRIMARY KEY
);
GRANT SELECT ON genotyping_primer_types TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON genotyping_primer_types TO "[% rw_role %]";

CREATE TABLE genotyping_primers (
       genotyping_primer_id     SERIAL PRIMARY KEY,
       genotyping_primer_type   TEXT NOT NULL REFERENCES genotyping_primer_types(genotyping_primer_type),
       design_id                INTEGER NOT NULL REFERENCES designs(design_id),
       genotyping_primer_seq    TEXT NOT NULL
);
GRANT SELECT ON genotyping_primers TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON genotyping_primers TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE genotyping_primers_genotyping_primer_id_seq TO "[% rw_role %]";

--
-- Pipelines and projects
--
CREATE TABLE pipelines (
       pipeline_id      SERIAL PRIMARY KEY,
       pipeline_name    TEXT UNIQUE,
       pipeline_desc    TEXT NOT NULL DEFAULT ''
);
GRANT SELECT ON pipelines TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON pipelines TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE pipelines_pipeline_id_seq TO "[% rw_role %]";

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
-- Processes (define before wells so well can have FK to process)
--
CREATE TABLE process_types (
       process_type            TEXT NOT NULL PRIMARY KEY,
       process_description     TEXT NOT NULL DEFAULT ''
);
GRANT SELECT ON process_types TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_types TO "[% rw_role %]";

CREATE TABLE processes (
       process_id           SERIAL PRIMARY KEY,
       process_type         TEXT NOT NULL REFERENCES process_types(process_type)
);  
GRANT SELECT ON processes TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON processes TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE processes_process_id_seq TO "[% rw_role %]";

CREATE TABLE process_pipeline (
       process_id           INTEGER PRIMARY KEY REFERENCES processes(process_id),
       pipeline_id          INTEGER NOT NULL REFERENCES pipelines(pipeline_id)
);
GRANT SELECT ON process_pipeline TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_pipeline TO "[% rw_role %]";

--
-- Data applicable to all wells
--
CREATE TABLE wells (
       well_id          SERIAL PRIMARY KEY,
       plate_id         INTEGER NOT NULL REFERENCES plates(plate_id),
       process_id       INTEGER NOT NULL REFERENCES processes(process_id),
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

CREATE INDEX ON wells(process_id);
CREATE INDEX ON wells(plate_id);

CREATE TABLE well_accepted_override (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       accepted            BOOLEAN NOT NULL,
       created_by          INTEGER NOT NULL REFERENCES users(user_id),
       created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON well_accepted_override TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_accepted_override TO "[% rw_role %]";

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
-- Premature optimization, hopefully redundant
--
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

--
-- Extra data for specific processes
--

CREATE TABLE process_rearray (
       process_id            INTEGER PRIMARY KEY REFERENCES processes(process_id)
);       
GRANT SELECT ON process_rearray TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_rearray TO "[% rw_role %]";

CREATE TABLE process_rearray_source_wells (
       process_id            INTEGER PRIMARY KEY REFERENCES process_rearray(process_id),
       source_well_id        INTEGER NOT NULL REFERENCES wells(well_id)
);
GRANT SELECT ON process_rearray_source_wells TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_rearray_source_wells TO "[% rw_role %]";

CREATE TABLE process_create_di (
       process_id           INTEGER PRIMARY KEY REFERENCES processes(process_id),
       design_id            INTEGER NOT NULL REFERENCES designs(design_id)
);
GRANT SELECT ON process_create_di TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_create_di TO "[% rw_role %]";

CREATE INDEX ON process_create_di(design_id);

CREATE TABLE process_create_di_bacs (
       process_id          INTEGER NOT NULL REFERENCES process_create_di(process_id),
       bac_plate           TEXT NOT NULL,
       bac_library         TEXT NOT NULL,
       bac_name            TEXT NOT NULL,
       UNIQUE(process_id, bac_plate),
       FOREIGN KEY(bac_name, bac_library) REFERENCES bac_clones(bac_name, bac_library)
);
GRANT SELECT ON process_create_di_bacs TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_create_di_bacs TO "[% rw_role %]";

CREATE TABLE process_int_recom (
       process_id        INTEGER PRIMARY KEY REFERENCES processes(process_id),
       design_well_id    INTEGER NOT NULL REFERENCES wells(well_id),
       cassette          TEXT NOT NULL,
       backbone          TEXT NOT NULL
);
GRANT SELECT ON process_int_recom TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_int_recom TO "[% rw_role %]";

CREATE TABLE process_cre_bac_recom (
       process_id        INTEGER PRIMARY KEY REFERENCES processes(process_id),
       design_id         INTEGER NOT NULL REFERENCES designs(design_id),
       bac_library       TEXT NOT NULL,
       bac_name          TEXT NOT NULL,
       cassette          TEXT NOT NULL,
       backbone          TEXT NOT NULL,
       FOREIGN KEY(bac_name, bac_library) REFERENCES bac_clones(bac_name,bac_library)
);
GRANT SELECT ON process_cre_bac_recom TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_cre_bac_recom TO "[% rw_role %]";

CREATE TABLE process_2w_gateway (
       process_id               INTEGER PRIMARY KEY REFERENCES processes(process_id),
       well_id                  INTEGER NOT NULL REFERENCES wells(well_id),
       cassette                 TEXT,
       backbone                 TEXT,
       CHECK( (cassette IS NULL AND backbone IS NOT NULL) OR (cassette IS NOT NULL AND backbone IS NULL) )
);
GRANT SELECT ON process_2w_gateway TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_2w_gateway TO "[% rw_role %]";

CREATE TABLE process_3w_gateway (
       process_id               INTEGER PRIMARY KEY REFERENCES processes(process_id),
       well_id                  INTEGER NOT NULL REFERENCES wells(well_id),
       cassette                 TEXT NOT NULL,
       backbone                 TEXT NOT NULL
);
GRANT SELECT ON process_3w_gateway TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_3w_gateway TO "[% rw_role %]";

--
-- Legacy sequencing QC results
--

CREATE TABLE well_legacy_qc_test_result (
       well_id             INTEGER PRIMARY KEY REFERENCES wells(well_id),
       qc_test_result_id   INTEGER NOT NULL,
       valid_primers       TEXT NOT NULL DEFAULT '',
       pass_level          TEXT NOT NULL
);
GRANT SELECT ON well_legacy_qc_test_result TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON well_legacy_qc_test_result TO "[% rw_role %]";

--
-- Data for sequencing QC
--

CREATE TABLE synthetic_constructs (
       synthetic_construct_id       SERIAL PRIMARY KEY,
       synthetic_construct_genbank  TEXT NOT NULL
);
GRANT SELECT ON synthetic_constructs TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON synthetic_constructs TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE synthetic_constructs_synthetic_construct_id_seq TO "[% rw_role %]";

CREATE TABLE process_synthetic_construct (
       process_id                   INTEGER PRIMARY KEY REFERENCES processes(process_id),
       synthetic_construct_id       INTEGER NOT NULL REFERENCES synthetic_constructs(synthetic_construct_id)
);
GRANT SELECT ON process_synthetic_construct TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON process_synthetic_construct TO "[% rw_role %]";

CREATE TABLE qc_templates (
       qc_template_id     SERIAL PRIMARY KEY,
       qc_template_name   TEXT NOT NULL
);
GRANT SELECT ON qc_templates TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_templates TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE qc_templates_qc_template_id_seq TO "[% rw_role %]";

CREATE TABLE qc_template_wells (
       qc_template_id     INTEGER NOT NULL REFERENCES qc_templates(qc_template_id),
       well_name          TEXT NOT NULL CHECK (well_name ~ '^[A-O](0[1-9]|1[0-9]|2[0-4])$'),
       process_id         INTEGER NOT NULL REFERENCES processes(process_id),
       PRIMARY KEY(qc_template_id, well_name)
);
GRANT SELECT ON qc_template_wells TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_template_wells TO "[% rw_role %]";

CREATE TABLE qc_runs (
       qc_run_id              CHAR(36) PRIMARY KEY,
       qc_run_date            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       sequencing_project     TEXT NOT NULL,
       profile                TEXT NOT NULL,
       qc_template_id         INTEGER NOT NULL REFERENCES qc_templates(qc_template_id),
       software_version       TEXT NOT NULL
);       
GRANT SELECT ON qc_runs TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_runs TO "[% rw_role %]";

CREATE TABLE qc_seq_reads (
       qc_seq_read_id     TEXT PRIMARY KEY,
       comment            TEXT NOT NULL DEFAULT '',
       fasta              TEXT NOT NULL
);
GRANT SELECT ON qc_seq_reads TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_seq_reads TO "[% rw_role %]";

CREATE TABLE qc_test_results (
       qc_test_result_id       SERIAL PRIMARY KEY,
       qc_run_id               CHAR(36) NOT NULL REFERENCES qc_runs(qc_run_id),
       synthetic_construct_id  INTEGER NOT NULL REFERENCES synthetic_constructs(synthetic_construct_id),
       well_name               TEXT NOT NULL,
       score                   INTEGER NOT NULL DEFAULT 0,
       pass                    BOOLEAN NOT NULL DEFAULT FALSE,
       UNIQUE(qc_run_id, synthetic_construct_id, well_name)
);
GRANT SELECT ON qc_test_results TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_test_results TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE qc_test_results_qc_test_result_id_seq TO "[% rw_role %]";

CREATE TABLE qc_test_result_alignments (
       qc_test_result_alignment_id SERIAL PRIMARY KEY,
       qc_seq_read_id              TEXT NOT NULL REFERENCES qc_seq_reads(qc_seq_read_id),
       primer_name                 TEXT NOT NULL,
       query_start                 INTEGER NOT NULL,
       query_end                   INTEGER NOT NULL,
       query_strand                INTEGER NOT NULL CHECK (query_strand IN (1, -1)),
       target_start                INTEGER NOT NULL,
       target_end                  INTEGER NOT NULL,
       target_strand               INTEGER NOT NULL CHECK (target_strand IN (1, -1)),
       score                       INTEGER NOT NULL,
       pass                        BOOLEAN NOT NULL DEFAULT FALSE
);
GRANT SELECT ON qc_test_result_alignments TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_test_result_alignments TO "[% rw_role %]";
GRANT USAGE ON SEQUENCE qc_test_result_alignments_qc_test_result_alignment_id_seq TO "[% rw_role %]";

CREATE TABLE qc_test_result_alignment_map (
       qc_test_result_id                  INTEGER NOT NULL REFERENCES qc_test_results(qc_test_result_id),
       qc_test_result_alignment_id        INTEGER NOT NULL REFERENCES qc_test_result_alignments(qc_test_result_alignment_id),
       PRIMARY KEY(qc_test_result_id, qc_test_result_alignment_id)
);
GRANT SELECT ON qc_test_result_alignment_map TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_test_result_alignment_map TO "[% rw_role %]";

CREATE TABLE qc_test_result_align_regions (
       qc_test_result_alignment_id        INTEGER NOT NULL REFERENCES qc_test_result_alignments(qc_test_result_alignment_id),
       name                               TEXT NOT NULL,
       length                             INTEGER NOT NULL,
       match_count                        INTEGER NOT NULL,
       query_str                          TEXT NOT NULL,
       target_str                         TEXT NOT NULL,
       match_str                          TEXT NOT NULL,
       pass                               BOOLEAN NOT NULL DEFAULT FALSE
);
GRANT SELECT ON qc_test_result_align_regions TO "[% ro_role %]";
GRANT SELECT, INSERT, UPDATE, DELETE ON qc_test_result_align_regions TO "[% rw_role %]";
