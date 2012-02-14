INSERT INTO roles (role_name)
VALUES ('admin'), ('edit'),('read');

INSERT INTO assemblies(assembly)
VALUES ('NCBIM34'), ('NCBIM36'), ('NCBIM37');

INSERT INTO chromosomes (chromosome)
VALUES ('1'), ('2'), ('3'), ('4'), ('5'), ('6'), ('7'), ('8'), ('9'),
       ('10'), ('11'), ('12'), ('13'), ('14'), ('15'), ('16'),
       ('17'), ('18'), ('19'), ('X'), ('Y');

INSERT INTO bac_libraries (bac_library) VALUES ('129'), ('black6');

INSERT INTO design_types(design_type)
VALUES ('conditional'), ('deletion'), ('insertion'), ('artificial-intron'), ('cre-bac');

INSERT INTO design_oligo_types(design_oligo_type)
VALUES ('G5'), ('U5'), ('U3'), ('D5'), ('D3'), ('G3');

INSERT INTO design_comment_categories(design_comment_category)
 VALUES ('Alternative variant not targeted'),
        ('NMD rescue'),
        ('Possible reinitiation'),
        ('Non protein coding locus'),
        ('Conserved elements'),
        ('Recovery design'),
        ('No NMD'),
        ('Other'),
        ('No BACs available'),
        ('Warning!'),
        ('Upstream domain unaffected'),
        ('Overlapping locus');      

INSERT INTO genotyping_primer_types(genotyping_primer_type)
VALUES ('GF1'), ('GF2'), ('GF3'), ('GF4'),
       ('GR1'), ('GR2'), ('GR3'), ('GR4'),
       ('LF1'), ('LF2'), ('LF3'),
       ('LR1'), ('LR2'), ('LR3'),
       ('PNFLR1'), ('PNFLR2'), ('PNFLR3'),
       ('EX3'), ('EX32'), ('EX5'), ('EX52');

INSERT INTO plate_types (plate_type) VALUES ('design'), ('pcs');

[% FOR assay IN [ 'rec_u', 'rec_d', 'rec_g', 'rec_ns', 'pcr_u', 'pcr_d', 'pcr_g', 'postcre' ] %]
INSERT INTO assay_result(assay,result)
VALUES ( '[% assay %]', 'pass' ), ( '[% assay %]', 'fail' ), ( '[% assay %]', 'weak' );
[% END %]

INSERT INTO assay_result(assay,result)
VALUES ( 'rec_result', 'pass' ), ( 'rec_result', 'fail' ),
       ( 'sequencing_qc', 'pass' ), ( 'sequencing_qc', 'fail' );
      
INSERT INTO process_types (process_type, process_description)
VALUES ( 'create_di', 'Instantiate Design' ),
       ( 'int_recom', 'Intermediate recombineering' ),
       ( 'bac_recom', 'BAC recombineering' ),
       ( '2w_gateway', 'Two-way gateway' ),
       ( '3w_gateway', 'Three-way gateway' ),
       ( 'rearray', 'Selection or re-array' ),
       ( 'rmce', 'Recombinase-mediated cassette exchange' ),
       ( '1st_ep', 'First allele electroporation' ),
       ( '2nd_ep', 'Second allele electroporation' ),
       ( 'flp', 'Flp recombinase' ),
       ( 'cre', 'Cre recombinase' ),
       ( 'dre', 'Dre recombinase' );

INSERT INTO pipelines (pipeline_name)
VALUES ( 'komp_csd' ),
       ( 'eucomm' ),
       ( 'eucomm_tools' ),
       ( 'eucomm_tools_cre' ),
       ( 'eucomm_tools_cre_bac' ),
       ( 'switch' );
       
       
