CREATE TABLE schema_versions (
       version      INTEGER NOT NULL,
       deployed_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (version, deployed_at)
);

GRANT SELECT ON schema_versions TO :admin_role, :ro_role, :rw_role;

CREATE TABLE users (
       user_id   SERIAL PRIMARY KEY,
       user_name TEXT NOT NULL UNIQUE CHECK (user_name <> '')
);

GRANT SELECT ON users TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO :rw_role;
GRANT USAGE ON SEQUENCE users_user_id_seq TO :rw_role;

CREATE TABLE roles (
       role_id    SERIAL PRIMARY KEY,
       role_name  TEXT NOT NULL UNIQUE CHECK (role_name <> '')
);

GRANT SELECT ON roles TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON roles TO :rw_role;
GRANT USAGE ON SEQUENCE roles_role_id_seq TO :rw_role;

INSERT INTO roles (role_name) VALUES ('admin');
INSERT INTO roles (role_name) VALUES ('edit');
INSERT INTO roles (role_name) VALUES ('read');

CREATE TABLE user_role (
       user_id INTEGER NOT NULL REFERENCES users(user_id),
       role_id INTEGER NOT NULL REFERENCES roles(role_id),
       PRIMARY KEY (user_id, role_id)
);

GRANT SELECT ON user_role TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_role TO :rw_role;

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
GRANT SELECT ON mgi_gene_data TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_gene_data TO :rw_role;

CREATE TABLE ensembl_gene_data (
       ensembl_gene_id         TEXT PRIMARY KEY,
       ensembl_gene_chromosome TEXT NOT NULL,
       ensembl_gene_start      INTEGER NOT NULL,
       ensembl_gene_end        INTEGER NOT NULL,
       ensembl_gene_strand     INTEGER NOT NULL CHECK (ensembl_gene_strand IN (1,-1)), 
       sp                      BOOLEAN NOT NULL,
       tm                      BOOLEAN NOT NULL
);       
GRANT SELECT ON ensembl_gene_data TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ensembl_gene_data TO :rw_role;

CREATE TABLE vega_gene_data (
       vega_gene_id         TEXT PRIMARY KEY,
       vega_gene_chromosome TEXT NOT NULL,
       vega_gene_start      INTEGER NOT NULL,
       vega_gene_end        INTEGER NOT NULL,
       vega_gene_strand     INTEGER NOT NULL CHECK (vega_gene_strand IN (1,-1))
);
GRANT SELECT ON vega_gene_data TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON vega_gene_data TO :rw_role;

CREATE TABLE mgi_ensembl_gene_map (
       mgi_accession_id           TEXT NOT NULL REFERENCES mgi_gene_data(mgi_accession_id),
       ensembl_gene_id            TEXT NOT NULL REFERENCES ensembl_gene_data(ensembl_gene_id),
       PRIMARY KEY(mgi_accession_id,ensembl_gene_id)
);
GRANT SELECT ON mgi_ensembl_gene_map TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_ensembl_gene_map TO :rw_role;

CREATE INDEX ON mgi_ensembl_gene_map(mgi_accession_id);
CREATE INDEX ON mgi_ensembl_gene_map(ensembl_gene_id);

CREATE TABLE mgi_vega_gene_map (
       mgi_accession_id           TEXT NOT NULL REFERENCES mgi_gene_data(mgi_accession_id),
       vega_gene_id               TEXT NOT NULL REFERENCES vega_gene_data(vega_gene_id),
       PRIMARY KEY(mgi_accession_id,vega_gene_id)
);
GRANT SELECT ON mgi_vega_gene_map TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_vega_gene_map TO :rw_role;

CREATE INDEX ON mgi_vega_gene_map(mgi_accession_id);
CREATE INDEX ON mgi_vega_gene_map(vega_gene_id);

CREATE TABLE genes (
       gene_id       SERIAL PRIMARY KEY
);
GRANT SELECT ON genes TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON genes TO :rw_role;
GRANT USAGE ON SEQUENCE genes_gene_id_seq TO :rw_role;

CREATE TABLE mgi_gene_map (
       gene_id          INTEGER NOT NULL REFERENCES genes(gene_id),
       mgi_accession_id TEXT NOT NULL,
       PRIMARY KEY(gene_id, mgi_accession_id)
);
GRANT SELECT ON mgi_gene_map TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mgi_gene_map TO :rw_role;
