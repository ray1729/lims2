use utf8;
package LIMS2::Schema::Result::ChangesetEntry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::ChangesetEntry

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<changeset_entries>

=cut

__PACKAGE__->table("changeset_entries");

=head1 ACCESSORS

=head2 changeset_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  is_nullable: 0

=head2 action

  data_type: 'text'
  is_nullable: 0

=head2 uri

  data_type: 'text'
  is_nullable: 0

=head2 data

  data_type: 'text'
  default_value: '{}'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "changeset_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "rank",
  { data_type => "integer", is_nullable => 0 },
  "action",
  { data_type => "text", is_nullable => 0 },
  "uri",
  { data_type => "text", is_nullable => 0 },
  "data",
  { data_type => "text", default_value => "{}", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</changeset_id>

=item * L</rank>

=back

=cut

__PACKAGE__->set_primary_key("changeset_id", "rank");

=head1 RELATIONS

=head2 changeset

Type: belongs_to

Related object: L<LIMS2::Schema::Result::Changeset>

=cut

__PACKAGE__->belongs_to(
  "changeset",
  "LIMS2::Schema::Result::Changeset",
  { changeset_id => "changeset_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-12-07 10:44:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kaNYxBwx/q1l3Ta8nynQSA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
