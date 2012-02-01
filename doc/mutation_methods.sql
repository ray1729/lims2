CREATE TABLE mutation_methods (
       mutation_method        TEXT PRIMARY KEY
);
GRANT SELECT ON mutation_methods TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mutation_methods TO :rw_role;

INSERT INTO mutation_methods(mutation_method) VALUES
( 'Targeted mutation' ),
( 'Recombination mediated cassette exchange' );

CREATE TABLE mutation_types (
       mutation_type        TEXT PRIMARY KEY
);
GRANT SELECT ON mutation_types TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mutation_types TO :rw_role;

INSERT INTO mutation_types(mutation_type) VALUES
( 'Conditional ready' ),
( 'Deletion' ),
( 'Targeted non-conditional' ),
( 'Cre knock-in' ),
( 'Cre BAC' );

CREATE TABLE mutation_subtypes (
       mutation_subtype     TEXT PRIMARY KEY
);       
GRANT SELECT ON mutation_subtypes TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mutation_subtypes TO :rw_role;

INSERT INTO mutation_subtypes (mutation_subtype) VALUES
( 'Domain disruption' ),
( 'Frameshift' ),
( 'Artificial Intron' ),
( 'Hprt' ),
( 'Rosa26' ),
( 'CDS' ),
( '3'' UTR' );

CREATE TABLE recombinases (
       recombinase      TEXT PRIMARY KEY
);

INSERT INTO recombinases(recombinase) VALUES ( 'Cre' ), ( 'Flp' ), ( 'Dre' );

CREATE TABLE recombinase_combinations (
       recombinase_combination_id SERIAL PRIMARY KEY
);

CREATE TABLE recombinase_combinations_recombinases (
       recombinase_combination_id INTEGER NOT NULL REFERENCES recombinase_combinations(recombinase_combination_id),
       recombinase                TEXT NOT NULL REFERENCES recombinases(recombinase),
       rank                       INTEGER NOT NULL,
       PRIMARY KEY(recombinase_combination_id, rank)
);

CREATE TABLE synthetic_constructs (
       synthetic_construct_id     SERIAL PRIMARY KEY
       type
);

CREATE TABLE intermediate_vectors (
       synthetic_construct_id   INTEGER PRIMARY KEY REFERENCES synthetic_constructs(synthetic_construct_id),
       design_id                INTEGER NOT NULL REFERENCES designs( design_id ),
       cassette                 TEXT NOT NULL,
       backbone                 TEXT NOT NULL,
       UNIQUE( design_id, cassette, backbone )
);

CREATE TABLE final_vectors (
       synthetic_construct_id     INTEGER PRIMARY KEY REFERENCES synthetic_constructs(synthetic_construct_id),
       design_id                  INTEGER NOT NULL REFERENCES designs( design_id ),
       cassette                   TEXT NOT NULL,
       backbone                   TEXT NOT NULL,
       recombinase_combination_id INTEGER NOT NULL REFERENCES recombinase_combinations(recombinase_combination_id),
       UNIQUE( design_id, cassette, backbone, recombinase_combination_id )
);

-- XXX needs a better name
CREATE TABLE es_cells (
       synthetic_construct_id   INTEGER PRIMARY KEY REFERENCES synthetic_constructs(synthetic_construct_id),
       first_allele_id          INTEGER NOT NULL REFERENCES final_vectors(synthetic_construct_id),
       second_allele_id         INTEGER REFERENCES final_vectors(synthetic_construct_id),
       UNIQUE(first_allele, second_allele)
);

wells:
 - well_id
 - plate_id
 - well_name
 - expected_synthetic_construct_id

assays:
 - assay_id - autoincrement
 - assay_type

assay_lrpcr
 - assay_id
 - well_id
 - synthetic_construct_id


assay_loa
 - assay_id
 - well_id
 - synthetic_construct_id


 - assay_result [pass, fail]

* Concern:
  - Assay completed on well on assumption that well has expected synthetic construct
  - Well is sequenced, observed a different synthetic construct
  - What does this mean for the previous assay?
