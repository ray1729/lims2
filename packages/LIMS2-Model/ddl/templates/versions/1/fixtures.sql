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

INSERT INTO design_comment_categories(design_comment_category_name)
 VALUES ('Alternative variant not targeted'),
        ('NMD Rescue'),
        ('Possible Reinitiation'),
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
