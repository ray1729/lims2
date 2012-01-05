--
-- Initial setup of users and schemas
-- You should set role to htgt_dba before running this.
--

CREATE ROLE lims2_admin NOLOGIN NOINHERIT;
CREATE ROLE lims2_rw  NOLOGIN NOINHERIT;
CREATE ROLE lims2_ro NOLOGIN NOINHERIT;
CREATE ROLE lims2_webapp WITH ENCRYPTED PASSWORD 'utohs9Aeyei3' LOGIN INHERIT IN ROLE lims2_ro;

CREATE ROLE "rm7@sanger.ac.uk" NOLOGIN INHERIT IN ROLE lims2_rw;
GRANT "rm7@sanger.ac.uk" TO lims2_webapp;

GRANT lims2_admin  TO rm7;
GRANT lims2_rw     TO rm7;
GRANT lims2_ro     TO rm7;
GRANT lims2_webapp TO rm7;

ALTER SCHEMA public OWNER TO lims2_admin;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO lims2_rw;
GRANT USAGE ON SCHEMA public TO lims2_ro;

CREATE SCHEMA audit AUTHORIZATION lims2_admin;
REVOKE ALL ON SCHEMA audit FROM PUBLIC;
GRANT USAGE ON SCHEMA audit TO lims2_rw;
GRANT USAGE ON SCHEMA audit TO lims2_ro;

