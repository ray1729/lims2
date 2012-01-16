--
-- Rename 'distribute' to 'accepted'
--

alter table wells rename column distribute to accepted;

alter table well_distribute_override rename column distribute_override to accepted;

alter table well_distribute_override rename to well_accepted_override;
