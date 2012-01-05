CREATE TABLE audit.bac_clones (
       audit_op         CHAR(1) NOT NULL,
       audit_user       TEXT NOT NULL,
       audit_stamp      TIMESTAMP NOT NULL,
       bac_clone_id     INTEGER NOT NULL,
       bac_name         TEXT NOT NULL,
       bac_library      TEXT NOT NULL
);
GRANT SELECT ON audit.bac_clones TO lims2_ro;
GRANT SELECT, INSERT ON audit.bac_clones TO lims2_rw;

CREATE OR REPLACE FUNCTION process_bac_clones_audit()
RETURNS TRIGGER AS $bac_clones_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.bac_clones SELECT 'D', user, now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.bac_clones SELECT 'U', user, now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.bac_clones SELECT 'I', user, now(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$bac_clones_audit$ LANGUAGE plpgsql;

CREATE TRIGGER bac_clones_audit
AFTER INSERT OR UPDATE OR DELETE ON bac_clones
    FOR EACH ROW EXECUTE PROCEDURE process_bac_clones_audit();

CREATE TABLE audit.bac_clone_loci (
       audit_op         CHAR(1) NOT NULL,
       audit_user       TEXT NOT NULL,
       audit_stamp      TIMESTAMP NOT NULL,
       bac_clone_id     INTEGER NOT NULL,
       assembly         TEXT NOT NULL,
       chromosome       TEXT NOT NULL,
       bac_start        INTEGER NOT NULL,
       bac_end          INTEGER NOT NULL
);
GRANT SELECT ON audit.bac_clone_loci TO lims2_ro;
GRANT SELECT, INSERT ON audit.bac_clone_loci TO lims2_rw;

CREATE OR REPLACE FUNCTION process_bac_clone_loci_audit()
RETURNS TRIGGER AS $bac_clone_loci_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
           INSERT INTO audit.bac_clone_loci SELECT 'D', user, now(), OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
           INSERT INTO audit.bac_clone_loci SELECT 'U', user, now(), NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
           INSERT INTO audit.bac_clone_loci SELECT 'I', user, now(), NEW.*;
        END IF;
        RETURN NULL;
    END;
$bac_clone_loci_audit$ LANGUAGE plpgsql;

CREATE TRIGGER bac_clone_loci_audit
AFTER INSERT OR UPDATE OR DELETE ON bac_clone_loci
    FOR EACH ROW EXECUTE PROCEDURE process_bac_clone_loci_audit();

