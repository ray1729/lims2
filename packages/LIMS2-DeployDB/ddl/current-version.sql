--
-- SQL to retrieve the current schema version
--
select version
from :schema_name.schema_versions
where deployed_at = (
  select max( deployed_at )
  from :schema_name.schema_versions
);
