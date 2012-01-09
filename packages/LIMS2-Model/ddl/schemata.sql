--
-- Initial setup of users and schemas
-- You should set role to htgt_dba before running this.
--

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public AUTHORIZATION lims2_admin;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO lims2_rw;
GRANT USAGE ON SCHEMA public TO lims2_ro;

DROP SCHEMA IF EXISTS audit CASCADE;
CREATE SCHEMA audit AUTHORIZATION lims2_admin;
REVOKE ALL ON SCHEMA audit FROM PUBLIC;
GRANT USAGE ON SCHEMA audit TO lims2_rw;
GRANT USAGE ON SCHEMA audit TO lims2_ro;

