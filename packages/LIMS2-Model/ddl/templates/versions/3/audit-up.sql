--
-- Rename 'distribute' to 'accepted'
--

alter table audit.wells rename column distribute to accepted;

alter table audit.well_distribute_override rename column distribute_override to accepted;

alter table audit.well_distribute_override rename to well_accepted_override;
