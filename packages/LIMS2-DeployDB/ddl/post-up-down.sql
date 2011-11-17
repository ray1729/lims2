--
-- SQL to be executed after up/down scripts have been run
--
INSERT INTO schema_versions (version) VALUES ( :to_version );

