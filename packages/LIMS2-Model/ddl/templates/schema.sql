DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public AUTHORIZATION "[% admin_role %]";
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO "[% rw_role %]";
GRANT USAGE ON SCHEMA public TO "[% ro_role %]";

DROP SCHEMA IF EXISTS audit CASCADE;
CREATE SCHEMA audit AUTHORIZATION "[% admin_role %]";
REVOKE ALL ON SCHEMA audit FROM PUBLIC;
GRANT USAGE ON SCHEMA audit TO "[% rw_role %]";
GRANT USAGE ON SCHEMA audit TO "[% ro_role %]";