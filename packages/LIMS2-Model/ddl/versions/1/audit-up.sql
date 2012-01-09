CREATE TABLE audit.user_role (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
user_id integer,
role_id integer
);
GRANT SELECT ON audit.user_role TO lims2_ro;
GRANT SELECT,INSERT ON audit.user_role TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_user_role_audit()
RETURNS TRIGGER AS $user_role_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.user_role SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.user_role SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.user_role SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$user_role_audit$ LANGUAGE plpgsql;
CREATE TRIGGER user_role_audit
AFTER INSERT OR UPDATE OR DELETE ON public.user_role
    FOR EACH ROW EXECUTE PROCEDURE public.process_user_role_audit();
CREATE TABLE audit.bac_clones (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
bac_name text,
bac_library text
);
GRANT SELECT ON audit.bac_clones TO lims2_ro;
GRANT SELECT,INSERT ON audit.bac_clones TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_bac_clones_audit()
RETURNS TRIGGER AS $bac_clones_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.bac_clones SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.bac_clones SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.bac_clones SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$bac_clones_audit$ LANGUAGE plpgsql;
CREATE TRIGGER bac_clones_audit
AFTER INSERT OR UPDATE OR DELETE ON public.bac_clones
    FOR EACH ROW EXECUTE PROCEDURE public.process_bac_clones_audit();
CREATE TABLE audit.users (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
user_id integer,
user_name text
);
GRANT SELECT ON audit.users TO lims2_ro;
GRANT SELECT,INSERT ON audit.users TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_users_audit()
RETURNS TRIGGER AS $users_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.users SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.users SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.users SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$users_audit$ LANGUAGE plpgsql;
CREATE TRIGGER users_audit
AFTER INSERT OR UPDATE OR DELETE ON public.users
    FOR EACH ROW EXECUTE PROCEDURE public.process_users_audit();
CREATE TABLE audit.design_oligo_types (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_oligo_type text
);
GRANT SELECT ON audit.design_oligo_types TO lims2_ro;
GRANT SELECT,INSERT ON audit.design_oligo_types TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_design_oligo_types_audit()
RETURNS TRIGGER AS $design_oligo_types_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.design_oligo_types SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.design_oligo_types SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.design_oligo_types SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$design_oligo_types_audit$ LANGUAGE plpgsql;
CREATE TRIGGER design_oligo_types_audit
AFTER INSERT OR UPDATE OR DELETE ON public.design_oligo_types
    FOR EACH ROW EXECUTE PROCEDURE public.process_design_oligo_types_audit();
CREATE TABLE audit.design_types (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_type text
);
GRANT SELECT ON audit.design_types TO lims2_ro;
GRANT SELECT,INSERT ON audit.design_types TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_design_types_audit()
RETURNS TRIGGER AS $design_types_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.design_types SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.design_types SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.design_types SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$design_types_audit$ LANGUAGE plpgsql;
CREATE TRIGGER design_types_audit
AFTER INSERT OR UPDATE OR DELETE ON public.design_types
    FOR EACH ROW EXECUTE PROCEDURE public.process_design_types_audit();
CREATE TABLE audit.chromosomes (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
chromosome text
);
GRANT SELECT ON audit.chromosomes TO lims2_ro;
GRANT SELECT,INSERT ON audit.chromosomes TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_chromosomes_audit()
RETURNS TRIGGER AS $chromosomes_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.chromosomes SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.chromosomes SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.chromosomes SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$chromosomes_audit$ LANGUAGE plpgsql;
CREATE TRIGGER chromosomes_audit
AFTER INSERT OR UPDATE OR DELETE ON public.chromosomes
    FOR EACH ROW EXECUTE PROCEDURE public.process_chromosomes_audit();
CREATE TABLE audit.bac_clone_loci (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
bac_name text,
bac_library text,
assembly text,
chr_name text,
chr_start integer,
chr_end integer
);
GRANT SELECT ON audit.bac_clone_loci TO lims2_ro;
GRANT SELECT,INSERT ON audit.bac_clone_loci TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_bac_clone_loci_audit()
RETURNS TRIGGER AS $bac_clone_loci_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.bac_clone_loci SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.bac_clone_loci SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.bac_clone_loci SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$bac_clone_loci_audit$ LANGUAGE plpgsql;
CREATE TRIGGER bac_clone_loci_audit
AFTER INSERT OR UPDATE OR DELETE ON public.bac_clone_loci
    FOR EACH ROW EXECUTE PROCEDURE public.process_bac_clone_loci_audit();
CREATE TABLE audit.roles (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
role_id integer,
role_name text
);
GRANT SELECT ON audit.roles TO lims2_ro;
GRANT SELECT,INSERT ON audit.roles TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_roles_audit()
RETURNS TRIGGER AS $roles_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.roles SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.roles SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.roles SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$roles_audit$ LANGUAGE plpgsql;
CREATE TRIGGER roles_audit
AFTER INSERT OR UPDATE OR DELETE ON public.roles
    FOR EACH ROW EXECUTE PROCEDURE public.process_roles_audit();
CREATE TABLE audit.schema_versions (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
version integer,
deployed_at timestamp without time zone
);
GRANT SELECT ON audit.schema_versions TO lims2_ro;
GRANT SELECT,INSERT ON audit.schema_versions TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_schema_versions_audit()
RETURNS TRIGGER AS $schema_versions_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.schema_versions SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.schema_versions SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.schema_versions SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$schema_versions_audit$ LANGUAGE plpgsql;
CREATE TRIGGER schema_versions_audit
AFTER INSERT OR UPDATE OR DELETE ON public.schema_versions
    FOR EACH ROW EXECUTE PROCEDURE public.process_schema_versions_audit();
CREATE TABLE audit.vega_gene_data (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
vega_gene_id text,
vega_gene_chromosome text,
vega_gene_start integer,
vega_gene_end integer,
vega_gene_strand integer
);
GRANT SELECT ON audit.vega_gene_data TO lims2_ro;
GRANT SELECT,INSERT ON audit.vega_gene_data TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_vega_gene_data_audit()
RETURNS TRIGGER AS $vega_gene_data_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.vega_gene_data SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.vega_gene_data SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.vega_gene_data SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$vega_gene_data_audit$ LANGUAGE plpgsql;
CREATE TRIGGER vega_gene_data_audit
AFTER INSERT OR UPDATE OR DELETE ON public.vega_gene_data
    FOR EACH ROW EXECUTE PROCEDURE public.process_vega_gene_data_audit();
CREATE TABLE audit.genes (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
gene_id integer
);
GRANT SELECT ON audit.genes TO lims2_ro;
GRANT SELECT,INSERT ON audit.genes TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_genes_audit()
RETURNS TRIGGER AS $genes_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.genes SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.genes SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.genes SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$genes_audit$ LANGUAGE plpgsql;
CREATE TRIGGER genes_audit
AFTER INSERT OR UPDATE OR DELETE ON public.genes
    FOR EACH ROW EXECUTE PROCEDURE public.process_genes_audit();
CREATE TABLE audit.mgi_ensembl_gene_map (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
mgi_accession_id text,
ensembl_gene_id text
);
GRANT SELECT ON audit.mgi_ensembl_gene_map TO lims2_ro;
GRANT SELECT,INSERT ON audit.mgi_ensembl_gene_map TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_mgi_ensembl_gene_map_audit()
RETURNS TRIGGER AS $mgi_ensembl_gene_map_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.mgi_ensembl_gene_map SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.mgi_ensembl_gene_map SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.mgi_ensembl_gene_map SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$mgi_ensembl_gene_map_audit$ LANGUAGE plpgsql;
CREATE TRIGGER mgi_ensembl_gene_map_audit
AFTER INSERT OR UPDATE OR DELETE ON public.mgi_ensembl_gene_map
    FOR EACH ROW EXECUTE PROCEDURE public.process_mgi_ensembl_gene_map_audit();
CREATE TABLE audit.design_oligos (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_id integer,
design_oligo_type text,
design_oligo_seq text
);
GRANT SELECT ON audit.design_oligos TO lims2_ro;
GRANT SELECT,INSERT ON audit.design_oligos TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_design_oligos_audit()
RETURNS TRIGGER AS $design_oligos_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.design_oligos SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.design_oligos SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.design_oligos SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$design_oligos_audit$ LANGUAGE plpgsql;
CREATE TRIGGER design_oligos_audit
AFTER INSERT OR UPDATE OR DELETE ON public.design_oligos
    FOR EACH ROW EXECUTE PROCEDURE public.process_design_oligos_audit();
CREATE TABLE audit.bac_libraries (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
bac_library text
);
GRANT SELECT ON audit.bac_libraries TO lims2_ro;
GRANT SELECT,INSERT ON audit.bac_libraries TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_bac_libraries_audit()
RETURNS TRIGGER AS $bac_libraries_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.bac_libraries SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.bac_libraries SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.bac_libraries SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$bac_libraries_audit$ LANGUAGE plpgsql;
CREATE TRIGGER bac_libraries_audit
AFTER INSERT OR UPDATE OR DELETE ON public.bac_libraries
    FOR EACH ROW EXECUTE PROCEDURE public.process_bac_libraries_audit();
CREATE TABLE audit.genotyping_primer_types (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
genotyping_primer_type text
);
GRANT SELECT ON audit.genotyping_primer_types TO lims2_ro;
GRANT SELECT,INSERT ON audit.genotyping_primer_types TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_genotyping_primer_types_audit()
RETURNS TRIGGER AS $genotyping_primer_types_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.genotyping_primer_types SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.genotyping_primer_types SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.genotyping_primer_types SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$genotyping_primer_types_audit$ LANGUAGE plpgsql;
CREATE TRIGGER genotyping_primer_types_audit
AFTER INSERT OR UPDATE OR DELETE ON public.genotyping_primer_types
    FOR EACH ROW EXECUTE PROCEDURE public.process_genotyping_primer_types_audit();
CREATE TABLE audit.design_oligo_loci (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_id integer,
design_oligo_type text,
assembly text,
chr_name text,
chr_start integer,
chr_end integer,
chr_strand integer
);
GRANT SELECT ON audit.design_oligo_loci TO lims2_ro;
GRANT SELECT,INSERT ON audit.design_oligo_loci TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_design_oligo_loci_audit()
RETURNS TRIGGER AS $design_oligo_loci_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.design_oligo_loci SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.design_oligo_loci SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.design_oligo_loci SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$design_oligo_loci_audit$ LANGUAGE plpgsql;
CREATE TRIGGER design_oligo_loci_audit
AFTER INSERT OR UPDATE OR DELETE ON public.design_oligo_loci
    FOR EACH ROW EXECUTE PROCEDURE public.process_design_oligo_loci_audit();
CREATE TABLE audit.designs (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_id integer,
design_name text,
created_by integer,
created_at timestamp without time zone,
design_type text,
phase integer,
validated_by_annotation text
);
GRANT SELECT ON audit.designs TO lims2_ro;
GRANT SELECT,INSERT ON audit.designs TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_designs_audit()
RETURNS TRIGGER AS $designs_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.designs SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.designs SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.designs SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$designs_audit$ LANGUAGE plpgsql;
CREATE TRIGGER designs_audit
AFTER INSERT OR UPDATE OR DELETE ON public.designs
    FOR EACH ROW EXECUTE PROCEDURE public.process_designs_audit();
CREATE TABLE audit.ensembl_gene_data (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
ensembl_gene_id text,
ensembl_gene_chromosome text,
ensembl_gene_start integer,
ensembl_gene_end integer,
ensembl_gene_strand integer,
sp boolean,
tm boolean
);
GRANT SELECT ON audit.ensembl_gene_data TO lims2_ro;
GRANT SELECT,INSERT ON audit.ensembl_gene_data TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_ensembl_gene_data_audit()
RETURNS TRIGGER AS $ensembl_gene_data_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.ensembl_gene_data SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.ensembl_gene_data SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.ensembl_gene_data SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$ensembl_gene_data_audit$ LANGUAGE plpgsql;
CREATE TRIGGER ensembl_gene_data_audit
AFTER INSERT OR UPDATE OR DELETE ON public.ensembl_gene_data
    FOR EACH ROW EXECUTE PROCEDURE public.process_ensembl_gene_data_audit();
CREATE TABLE audit.mgi_gene_data (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
mgi_accession_id text,
marker_type text,
marker_symbol text,
marker_name text,
representative_genome_id text,
representative_genome_chr text,
representative_genome_start integer,
representative_genome_end integer,
representative_genome_strand integer,
representative_genome_build text,
entrez_gene_id text,
ncbi_gene_chromosome text,
ncbi_gene_start integer,
ncbi_gene_end integer,
ncbi_gene_strand integer,
unists_gene_chromosome text,
unists_gene_start integer,
unists_gene_end integer,
mgi_qtl_gene_chromosome text,
mgi_qtl_gene_start integer,
mgi_qtl_gene_end integer,
mirbase_gene_id text,
mirbase_gene_chromosome text,
mirbase_gene_start integer,
mirbase_gene_end integer,
mirbase_gene_strand integer,
roopenian_sts_gene_start integer,
roopenian_sts_gene_end integer
);
GRANT SELECT ON audit.mgi_gene_data TO lims2_ro;
GRANT SELECT,INSERT ON audit.mgi_gene_data TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_mgi_gene_data_audit()
RETURNS TRIGGER AS $mgi_gene_data_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.mgi_gene_data SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.mgi_gene_data SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.mgi_gene_data SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$mgi_gene_data_audit$ LANGUAGE plpgsql;
CREATE TRIGGER mgi_gene_data_audit
AFTER INSERT OR UPDATE OR DELETE ON public.mgi_gene_data
    FOR EACH ROW EXECUTE PROCEDURE public.process_mgi_gene_data_audit();
CREATE TABLE audit.design_comment_categories (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_comment_category_id integer,
desgin_comment_category_name text
);
GRANT SELECT ON audit.design_comment_categories TO lims2_ro;
GRANT SELECT,INSERT ON audit.design_comment_categories TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_design_comment_categories_audit()
RETURNS TRIGGER AS $design_comment_categories_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.design_comment_categories SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.design_comment_categories SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.design_comment_categories SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$design_comment_categories_audit$ LANGUAGE plpgsql;
CREATE TRIGGER design_comment_categories_audit
AFTER INSERT OR UPDATE OR DELETE ON public.design_comment_categories
    FOR EACH ROW EXECUTE PROCEDURE public.process_design_comment_categories_audit();
CREATE TABLE audit.mgi_vega_gene_map (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
mgi_accession_id text,
vega_gene_id text
);
GRANT SELECT ON audit.mgi_vega_gene_map TO lims2_ro;
GRANT SELECT,INSERT ON audit.mgi_vega_gene_map TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_mgi_vega_gene_map_audit()
RETURNS TRIGGER AS $mgi_vega_gene_map_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.mgi_vega_gene_map SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.mgi_vega_gene_map SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.mgi_vega_gene_map SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$mgi_vega_gene_map_audit$ LANGUAGE plpgsql;
CREATE TRIGGER mgi_vega_gene_map_audit
AFTER INSERT OR UPDATE OR DELETE ON public.mgi_vega_gene_map
    FOR EACH ROW EXECUTE PROCEDURE public.process_mgi_vega_gene_map_audit();
CREATE TABLE audit.gene_comments (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
gene_comment_id integer,
gene_id integer,
gene_comment text,
is_public boolean,
created_by integer,
created_date timestamp without time zone
);
GRANT SELECT ON audit.gene_comments TO lims2_ro;
GRANT SELECT,INSERT ON audit.gene_comments TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_gene_comments_audit()
RETURNS TRIGGER AS $gene_comments_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.gene_comments SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.gene_comments SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.gene_comments SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$gene_comments_audit$ LANGUAGE plpgsql;
CREATE TRIGGER gene_comments_audit
AFTER INSERT OR UPDATE OR DELETE ON public.gene_comments
    FOR EACH ROW EXECUTE PROCEDURE public.process_gene_comments_audit();
CREATE TABLE audit.mgi_gene_map (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
gene_id integer,
mgi_accession_id text
);
GRANT SELECT ON audit.mgi_gene_map TO lims2_ro;
GRANT SELECT,INSERT ON audit.mgi_gene_map TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_mgi_gene_map_audit()
RETURNS TRIGGER AS $mgi_gene_map_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.mgi_gene_map SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.mgi_gene_map SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.mgi_gene_map SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$mgi_gene_map_audit$ LANGUAGE plpgsql;
CREATE TRIGGER mgi_gene_map_audit
AFTER INSERT OR UPDATE OR DELETE ON public.mgi_gene_map
    FOR EACH ROW EXECUTE PROCEDURE public.process_mgi_gene_map_audit();
CREATE TABLE audit.design_comments (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
design_comment_id integer,
design_comment_category_id integer,
design_id integer,
design_comment text,
is_public boolean,
created_by integer,
created_date timestamp without time zone
);
GRANT SELECT ON audit.design_comments TO lims2_ro;
GRANT SELECT,INSERT ON audit.design_comments TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_design_comments_audit()
RETURNS TRIGGER AS $design_comments_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.design_comments SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.design_comments SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.design_comments SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$design_comments_audit$ LANGUAGE plpgsql;
CREATE TRIGGER design_comments_audit
AFTER INSERT OR UPDATE OR DELETE ON public.design_comments
    FOR EACH ROW EXECUTE PROCEDURE public.process_design_comments_audit();
CREATE TABLE audit.assemblies (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
assembly text
);
GRANT SELECT ON audit.assemblies TO lims2_ro;
GRANT SELECT,INSERT ON audit.assemblies TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_assemblies_audit()
RETURNS TRIGGER AS $assemblies_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.assemblies SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.assemblies SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.assemblies SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$assemblies_audit$ LANGUAGE plpgsql;
CREATE TRIGGER assemblies_audit
AFTER INSERT OR UPDATE OR DELETE ON public.assemblies
    FOR EACH ROW EXECUTE PROCEDURE public.process_assemblies_audit();
CREATE TABLE audit.genotyping_primers (
audit_op CHAR(1) NOT NULL CHECK (audit_op IN ('D','I','U')),
audit_user TEXT NOT NULL,
audit_stamp TIMESTAMP NOT NULL,
audit_txid INTEGER NOT NULL,
genotyping_primer_id integer,
genotyping_primer_type text,
design_id integer,
genotyping_primer_seq text
);
GRANT SELECT ON audit.genotyping_primers TO lims2_ro;
GRANT SELECT,INSERT ON audit.genotyping_primers TO lims2_rw;
CREATE OR REPLACE FUNCTION public.process_genotyping_primers_audit()
RETURNS TRIGGER AS $genotyping_primers_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.genotyping_primers SELECT 'D', user, now(), txid_current(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.genotyping_primers SELECT 'U', user, now(), txid_current(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.genotyping_primers SELECT 'I', user, now(), txid_current(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$genotyping_primers_audit$ LANGUAGE plpgsql;
CREATE TRIGGER genotyping_primers_audit
AFTER INSERT OR UPDATE OR DELETE ON public.genotyping_primers
    FOR EACH ROW EXECUTE PROCEDURE public.process_genotyping_primers_audit();
