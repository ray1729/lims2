
CREATE TABLE assemblies (
       assembly         TEXT PRIMARY KEY
);
GRANT SELECT ON assemblies TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON assemblies TO :rw_role;

INSERT INTO assemblies(assembly) VALUES( 'NCBIM34' );
INSERT INTO assemblies(assembly) VALUES( 'NCBIM36' );
INSERT INTO assemblies(assembly) VALUES( 'NCBIM37' );

CREATE TABLE chromosomes (
       chromosome        TEXT PRIMARY KEY
);
GRANT SELECT ON chromosomes TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON chromosomes TO :rw_role;

INSERT INTO chromosomes (chromosome) VALUES ( '1' );
INSERT INTO chromosomes (chromosome) VALUES ( '2' );
INSERT INTO chromosomes (chromosome) VALUES ( '3' );
INSERT INTO chromosomes (chromosome) VALUES ( '4' );
INSERT INTO chromosomes (chromosome) VALUES ( '5' );
INSERT INTO chromosomes (chromosome) VALUES ( '6' );
INSERT INTO chromosomes (chromosome) VALUES ( '7' );
INSERT INTO chromosomes (chromosome) VALUES ( '8' );
INSERT INTO chromosomes (chromosome) VALUES ( '9' );
INSERT INTO chromosomes (chromosome) VALUES ( '10' );
INSERT INTO chromosomes (chromosome) VALUES ( '11' );
INSERT INTO chromosomes (chromosome) VALUES ( '12' );
INSERT INTO chromosomes (chromosome) VALUES ( '13' );
INSERT INTO chromosomes (chromosome) VALUES ( '14' );
INSERT INTO chromosomes (chromosome) VALUES ( '15' );
INSERT INTO chromosomes (chromosome) VALUES ( '16' );
INSERT INTO chromosomes (chromosome) VALUES ( '17' );
INSERT INTO chromosomes (chromosome) VALUES ( '18' );
INSERT INTO chromosomes (chromosome) VALUES ( '19' );
INSERT INTO chromosomes (chromosome) VALUES ( 'X' );
INSERT INTO chromosomes (chromosome) VALUES ( 'Y' );

CREATE TABLE bac_libraries (
       bac_library    TEXT PRIMARY KEY
);
GRANT SELECT ON bac_libraries TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_libraries TO :rw_role;

INSERT INTO bac_libraries (bac_library) VALUES ( '129' );
INSERT INTO bac_libraries (bac_library) VALUES ( 'black6' );

CREATE TABLE bac_clones (
       bac_clone_id     SERIAL PRIMARY KEY,
       bac_name         TEXT NOT NULL,
       bac_library      TEXT NOT NULL REFERENCES bac_libraries(bac_library)
);
GRANT SELECT ON bac_clones TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_clones TO :rw_role;
GRANT USAGE ON SEQUENCE bac_clones_bac_clone_id_seq TO :rw_role;

CREATE TABLE bac_clone_loci (
       bac_clone_id     INTEGER NOT NULL REFERENCES bac_clones(bac_clone_id),
       assembly         TEXT NOT NULL REFERENCES assemblies(assembly),
       chromosome       TEXT NOT NULL REFERENCES chromosomes(chromosome),
       bac_start        INTEGER NOT NULL,
       bac_end          INTEGER NOT NULL
);
GRANT SELECT ON bac_clone_loci TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON bac_clone_loci TO :rw_role;

CREATE TABLE design_types (
       design_type        TEXT PRIMARY KEY
);
GRANT SELECT ON design_types TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_types TO :rw_role;

INSERT INTO design_types(design_type) VALUES('conditional');
INSERT INTO design_types(design_type) VALUES('deletion');
INSERT INTO design_types(design_type) VALUES('artificial-intron');
INSERT INTO design_types(design_type) VALUES('cre-bac');

CREATE TABLE designs (
       design_id                INTEGER PRIMARY KEY,
       design_name              TEXT,
       created_user             INTEGER NOT NULL REFERENCES users(user_id),
       created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
       design_type              TEXT NOT NULL REFERENCES design_types(design_type),
       phase                    INTEGER NOT NULL,
       validated_by_annotation  BOOLEAN NOT NULL DEFAULT FALSE
);
GRANT SELECT ON designs TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON designs TO :rw_role;
       
CREATE TABLE design_oligo_types (
       design_oligo_type TEXT PRIMARY KEY
);

GRANT SELECT ON design_oligo_types TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligo_types TO :rw_role;

INSERT INTO design_oligo_types(design_oligo_type) VALUES ( 'G5' );
INSERT INTO design_oligo_types(design_oligo_type) VALUES ( 'U5' );
INSERT INTO design_oligo_types(design_oligo_type) VALUES ( 'U3' );
INSERT INTO design_oligo_types(design_oligo_type) VALUES ( 'D5' );
INSERT INTO design_oligo_types(design_oligo_type) VALUES ( 'D3' );
INSERT INTO design_oligo_types(design_oligo_type) VALUES ( 'G3' );

CREATE TABLE design_oligos (
       design_id         INTEGER NOT NULL REFERENCES designs(design_id),
       design_oligo_type TEXT NOT NULL REFERENCES design_oligo_types(design_oligo_type),
       design_oligo_seq  TEXT NOT NULL,
       PRIMARY KEY(design_id, design_oligo_type)
);

GRANT SELECT ON design_oligos TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligos TO :rw_role;

CREATE TABLE design_oligo_loci (
       design_id         INTEGER NOT NULL,
       design_oligo_type TEXT NOT NULL,
       assembly          TEXT NOT NULL REFERENCES assemblies(assembly),
       chr_name          TEXT NOT NULL,
       chr_start         INTEGER NOT NULL,
       chr_end           INTEGER NOT NULL,
       chr_strand        INTEGER NOT NULL CHECK (chr_strand IN (1, -1)),
       PRIMARY KEY (design_id, design_oligo_type, assembly),
       FOREIGN KEY (design_id, design_oligo_type) REFERENCES design_oligos(design_id, design_oligo_type),
       CHECK ( chr_start <= chr_end )
);

GRANT SELECT ON design_oligo_loci TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_oligo_loci TO :rw_role;

CREATE TABLE design_comment_categories (
       design_comment_category_id      SERIAL PRIMARY KEY,
       design_comment_category_name    TEXT NOT NULL UNIQUE
);
GRANT SELECT ON design_comment_categories TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_comment_categories TO :rw_role;
GRANT USAGE ON SEQUENCE design_comment_categories_design_comment_category_id_seq TO :rw_role;

INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Alternative variant not targeted');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('NMD Rescue');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Possible Reinitiation');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Non protein coding locus');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Conserved elements');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Recovery design');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('No NMD');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Other');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('No BACs available');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Warning!');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Upstream domain unaffected');      
INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Overlapping locus');      
--INSERT INTO design_comment_categories(design_comment_category_name) VALUES('Artificial intron design');      

CREATE TABLE design_comments (
       design_comment_id          SERIAL PRIMARY KEY,
       design_comment_category_id INTEGER NOT NULL REFERENCES design_comment_categories(design_comment_category_id),
       design_id                  INTEGER NOT NULL REFERENCES designs(design_id),
       design_comment             TEXT NOT NULL DEFAULT '',
       is_public                  BOOLEAN NOT NULL DEFAULT FALSE,
       created_by                 INTEGER NOT NULL REFERENCES users(user_id),
       created_date               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON design_comments TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON design_comments TO :rw_role;
GRANT USAGE ON SEQUENCE design_comments_design_comment_id_seq TO :rw_role;

CREATE TABLE gene_comments (
       gene_comment_id     SERIAL PRIMARY KEY,
       gene_id             INTEGER NOT NULL REFERENCES genes(gene_id),
       gene_comment        TEXT NOT NULL,
       is_public           BOOLEAN NOT NULL DEFAULT FALSE,
       created_by          INTEGER NOT NULL REFERENCES users(user_id),
       created_date        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
GRANT SELECT ON gene_comments TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON gene_comments TO :rw_role;
GRANT USAGE ON SEQUENCE gene_comments_gene_comment_id_seq TO :rw_role;

CREATE TABLE genotyping_primer_types (
       genotyping_primer_type TEXT PRIMARY KEY
);
GRANT SELECT ON genotyping_primer_types TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON genotyping_primer_types TO :rw_role;

INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GF1');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GF2');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GF3');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GF4');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GR1');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GR2');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GR3');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('GR4');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('LF1');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('LF2');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('LF3');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('LR1');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('LR2');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('LR3');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('PNFLR1');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('PNFLR2');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('PNFLR3');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('EX3');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('EX32');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('EX5');
INSERT INTO genotyping_primer_types(genotyping_primer_type) VALUES('EX52');

CREATE TABLE genotyping_primers (
       genotyping_primer_id     SERIAL PRIMARY KEY,
       genotyping_primer_type   TEXT NOT NULL REFERENCES genotyping_primer_types(genotyping_primer_type),
       design_id                INTEGER NOT NULL REFERENCES designs(design_id),
       seq                      TEXT NOT NULL
);
GRANT SELECT ON genotyping_primers TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON genotyping_primers TO :rw_role;
GRANT USAGE ON SEQUENCE genotyping_primers_genotyping_primer_id_seq TO :rw_role;
