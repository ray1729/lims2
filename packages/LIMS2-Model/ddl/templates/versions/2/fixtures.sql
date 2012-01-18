INSERT INTO plate_types (plate_type) VALUES ('design');

[% FOR assay IN [ 'rec_u', 'rec_d', 'rec_g', 'rec_ns', 'pcr_u', 'pcr_d', 'pcr_g', 'postcre' ] %]
INSERT INTO assay_result(assay,result)
VALUES ( '[% assay %]', 'pass' ), ( '[% assay %]', 'fail' ), ( '[% assay %]', 'weak' );
[% END %]

INSERT INTO assay_result(assay,result)
VALUES ( 'rec_result', 'pass' ), ( 'rec_result', 'fail' );
