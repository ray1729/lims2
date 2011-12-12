CREATE TABLE mutation_methods (
       mutation_method        TEXT PRIMARY KEY
);
GRANT SELECT ON mutation_methods TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mutation_methods TO :rw_role;

INSERT INTO mutation_methods(mutation_method) VALUES ( 'Targeted mutation' );
INSERT INTO mutation_methods(mutation_method) VALUES ( 'Recombination mediated cassette exchange' );

CREATE TABLE mutation_types (
       mutation_type        TEXT PRIMARY KEY
);
GRANT SELECT ON mutation_types TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mutation_types TO :rw_role;

INSERT INTO mutation_types(mutation_type) VALUES ( 'Conditional ready' );
INSERT INTO mutation_types(mutation_type) VALUES ( 'Deletion' );
INSERT INTO mutation_types(mutation_type) VALUES ( 'Targeted non-conditional' );
INSERT INTO mutation_types(mutation_type) VALUES ( 'Cre knock-in' );
INSERT INTO mutation_types(mutation_type) VALUES ( 'Cre BAC' );

CREATE TABLE mutation_subtypes (
       mutation_subtype     TEXT PRIMARY KEY
);       
GRANT SELECT ON mutation_subtypes TO :ro_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON mutation_subtypes TO :rw_role;

INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( 'Domain disruption' );
INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( 'Frameshift' );
INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( 'Artificial Intron' );
INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( 'Hprt' );
INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( 'Rosa26' );
INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( 'CDS' );
INSERT INTO mutation_subtypes (mutation_subtype) VALUES ( '3'' UTR' );
