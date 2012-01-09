CREATE TABLE schema_versions (
       version      INTEGER NOT NULL,
       deployed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (version, deployed_at)
);
GRANT SELECT ON schema_versions TO lims2_ro, lims2_rw;

CREATE TABLE users (
       user_id   SERIAL PRIMARY KEY,
       user_name TEXT NOT NULL UNIQUE CHECK (user_name <> '')
);

GRANT SELECT ON users TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO lims2_rw;
GRANT USAGE ON SEQUENCE users_user_id_seq TO lims2_rw;

CREATE TABLE roles (
       role_id    SERIAL PRIMARY KEY,
       role_name  TEXT NOT NULL UNIQUE CHECK (role_name <> '')
);

GRANT SELECT ON roles TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON roles TO lims2_rw;
GRANT USAGE ON SEQUENCE roles_role_id_seq TO lims2_rw;

CREATE TABLE user_role (
       user_id INTEGER NOT NULL REFERENCES users(user_id),
       role_id INTEGER NOT NULL REFERENCES roles(role_id),
       PRIMARY KEY (user_id, role_id)
);

GRANT SELECT ON user_role TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_role TO lims2_rw;

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
GRANT SELECT ON mgi_gene_data TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_gene_data TO lims2_rw;

CREATE TABLE ensembl_gene_data (
       ensembl_gene_id         TEXT PRIMARY KEY,
       ensembl_gene_chromosome TEXT NOT NULL,
       ensembl_gene_start      INTEGER NOT NULL,
       ensembl_gene_end        INTEGER NOT NULL,
       ensembl_gene_strand     INTEGER NOT NULL CHECK (ensembl_gene_strand IN (1,-1)), 
       sp                      BOOLEAN NOT NULL,
       tm                      BOOLEAN NOT NULL
);       
GRANT SELECT ON ensembl_gene_data TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON ensembl_gene_data TO lims2_rw;

CREATE TABLE vega_gene_data (
       vega_gene_id         TEXT PRIMARY KEY,
       vega_gene_chromosome TEXT NOT NULL,
       vega_gene_start      INTEGER NOT NULL,
       vega_gene_end        INTEGER NOT NULL,
       vega_gene_strand     INTEGER NOT NULL CHECK (vega_gene_strand IN (1,-1))
);
GRANT SELECT ON vega_gene_data TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON vega_gene_data TO lims2_rw;

CREATE TABLE mgi_ensembl_gene_map (
       mgi_accession_id           TEXT NOT NULL REFERENCES mgi_gene_data(mgi_accession_id),
       ensembl_gene_id            TEXT NOT NULL REFERENCES ensembl_gene_data(ensembl_gene_id),
       PRIMARY KEY(mgi_accession_id,ensembl_gene_id)
);
GRANT SELECT ON mgi_ensembl_gene_map TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_ensembl_gene_map TO lims2_rw;

CREATE INDEX ON mgi_ensembl_gene_map(mgi_accession_id);
CREATE INDEX ON mgi_ensembl_gene_map(ensembl_gene_id);

CREATE TABLE mgi_vega_gene_map (
       mgi_accession_id           TEXT NOT NULL REFERENCES mgi_gene_data(mgi_accession_id),
       vega_gene_id               TEXT NOT NULL REFERENCES vega_gene_data(vega_gene_id),
       PRIMARY KEY(mgi_accession_id,vega_gene_id)
);
GRANT SELECT ON mgi_vega_gene_map TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_vega_gene_map TO lims2_rw;

CREATE INDEX ON mgi_vega_gene_map(mgi_accession_id);
CREATE INDEX ON mgi_vega_gene_map(vega_gene_id);

CREATE TABLE genes (
       gene_id       SERIAL PRIMARY KEY
);
GRANT SELECT ON genes TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON genes TO lims2_rw;
GRANT USAGE ON SEQUENCE genes_gene_id_seq TO lims2_rw;

CREATE TABLE mgi_gene_map (
       gene_id          INTEGER NOT NULL REFERENCES genes(gene_id),
       mgi_accession_id TEXT NOT NULL,
       PRIMARY KEY(gene_id, mgi_accession_id)
);
GRANT SELECT ON mgi_gene_map TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_gene_map TO lims2_rw;

CREATE INDEX ON mgi_gene_map(gene_id);
CREATE INDEX ON mgi_gene_map(mgi_accession_id);

CREATE TABLE assemblies (
       assembly         TEXT PRIMARY KEY
);
GRANT SELECT ON assemblies TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON assemblies TO lims2_rw;

CREATE TABLE chromosomes (
       chromosome  TEXT PRIMARY KEY
);
GRANT SELECT ON chromosomes TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON chromosomes TO lims2_rw;

CREATE TABLE bac_libraries (
       bac_library    TEXT PRIMARY KEY
);
GRANT SELECT ON bac_libraries TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_libraries TO lims2_rw;

CREATE TABLE bac_clones (
       bac_name         TEXT NOT NULL,
       bac_library      TEXT NOT NULL REFERENCES bac_libraries(bac_library),
       PRIMARY KEY (bac_name, bac_library)
);
GRANT SELECT ON bac_clones TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_clones TO lims2_rw;

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
GRANT SELECT ON bac_clone_loci TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_clone_loci TO lims2_rw;

CREATE TABLE design_types (
       design_type        TEXT PRIMARY KEY
);
GRANT SELECT ON design_types TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_types TO lims2_rw;

CREATE TABLE designs (
       design_id                INTEGER PRIMARY KEY,
       design_name              TEXT,
       created_by               INTEGER NOT NULL REFERENCES users(user_id),
       created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       design_type              TEXT NOT NULL REFERENCES design_types(design_type),
       phase                    INTEGER NOT NULL,
       validated_by_annotation  TEXT CHECK (validated_by_annotation IS NULL OR validated_by_annotation IN ( 'yes', 'no', 'maybe' ))
);
GRANT SELECT ON designs TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON designs TO lims2_rw;
       
CREATE TABLE design_oligo_types (
       design_oligo_type TEXT PRIMARY KEY
);

GRANT SELECT ON design_oligo_types TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligo_types TO lims2_rw;

CREATE TABLE design_oligos (
       design_id         INTEGER NOT NULL REFERENCES designs(design_id),
       design_oligo_type TEXT NOT NULL REFERENCES design_oligo_types(design_oligo_type),
       design_oligo_seq  TEXT NOT NULL,
       PRIMARY KEY(design_id, design_oligo_type)
);

GRANT SELECT ON design_oligos TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligos TO lims2_rw;

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

GRANT SELECT ON design_oligo_loci TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligo_loci TO lims2_rw;

CREATE TABLE design_comment_categories (
       design_comment_category_id      SERIAL PRIMARY KEY,
       desgin_comment_category_name    TEXT NOT NULL UNIQUE
);
GRANT SELECT ON design_comment_categories TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_comment_categories TO lims2_rw;
GRANT USAGE ON SEQUENCE design_comment_categories_design_comment_category_id_seq TO lims2_rw;

CREATE TABLE design_comments (
       design_comment_id          SERIAL PRIMARY KEY,
       design_comment_category_id INTEGER NOT NULL REFERENCES design_comment_categories(design_comment_category_id),
       design_id                  INTEGER NOT NULL REFERENCES designs(design_id),
       design_comment             TEXT NOT NULL DEFAULT '',
       is_public                  BOOLEAN NOT NULL DEFAULT FALSE,
       created_by                 INTEGER NOT NULL REFERENCES users(user_id),
       created_at                 TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON design_comments TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_comments TO lims2_rw;
GRANT USAGE ON SEQUENCE design_comments_design_comment_id_seq TO lims2_rw;

CREATE TABLE gene_comments (
       gene_comment_id     SERIAL PRIMARY KEY,
       gene_id             INTEGER NOT NULL REFERENCES genes(gene_id),
       gene_comment        TEXT NOT NULL,
       is_public           BOOLEAN NOT NULL DEFAULT FALSE,
       created_by          INTEGER NOT NULL REFERENCES users(user_id),
       created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON gene_comments TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON gene_comments TO lims2_rw;
GRANT USAGE ON SEQUENCE gene_comments_gene_comment_id_seq TO lims2_rw;

CREATE TABLE genotyping_primer_types (
       genotyping_primer_type TEXT PRIMARY KEY
);
GRANT SELECT ON genotyping_primer_types TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON genotyping_primer_types TO lims2_rw;

CREATE TABLE genotyping_primers (
       genotyping_primer_id     SERIAL PRIMARY KEY,
       genotyping_primer_type   TEXT NOT NULL REFERENCES genotyping_primer_types(genotyping_primer_type),
       design_id                INTEGER NOT NULL REFERENCES designs(design_id),
       genotyping_primer_seq    TEXT NOT NULL
);
GRANT SELECT ON genotyping_primers TO lims2_ro;
GRANT SELECT, INSERT, UPDATE, DELETE ON genotyping_primers TO lims2_rw;
GRANT USAGE ON SEQUENCE genotyping_primers_genotyping_primer_id_seq TO lims2_rw;
