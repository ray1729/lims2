CREATE ROLE "[% admin_role  %]" NOLOGIN NOINHERIT;
CREATE ROLE "[% rw_role     %]" NOLOGIN NOINHERIT;
CREATE ROLE "[% ro_role     %]" NOLOGIN NOINHERIT;
CREATE ROLE "[% webapp_role %]" WITH ENCRYPTED PASSWORD '[% webapp_passwd %]' LOGIN NOINHERIT IN ROLE "[% ro_role %]";
CREATE ROLE "[% task_role   %]" WITH ENCRYPTED PASSWORD '[% task_passwd %]' LOGIN INHERIT IN ROLE "[% rw_role %]";
CREATE ROLE "[% test_role   %]" WITH ENCRYPTED PASSWORD '[% test_passwd %]' LOGIN INHERIT IN ROLE "[% rw_role %]";

[%- FOR u IN webapp_users %]
GRANT "[% rw_role %]" TO "[% u %]";
GRANT "[% u %]" TO "[% webapp_role %]";
[%- END %]

[%- FOR u IN system_users %]
  [%- FOR r IN [ admin_role ro_role rw_role ] %]
GRANT "[% r %]" TO "[% u %]";
  [%- END %]
[%- END %]

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
