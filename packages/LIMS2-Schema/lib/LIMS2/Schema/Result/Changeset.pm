use utf8;
package LIMS2::Schema::Result::Changeset;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::Changeset

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

=head1 TABLE: C<changesets>

=cut

__PACKAGE__->table("changesets");

=head1 ACCESSORS

=head2 changeset_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'changesets_changeset_id_seq'

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "changeset_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "changesets_changeset_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</changeset_id>

=back

=cut

__PACKAGE__->set_primary_key("changeset_id");

=head1 RELATIONS

=head2 changeset_entries

Type: has_many

Related object: L<LIMS2::Schema::Result::ChangesetEntry>

=cut

__PACKAGE__->has_many(
  "changeset_entries",
  "LIMS2::Schema::Result::ChangesetEntry",
  { "foreign.changeset_id" => "self.changeset_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<LIMS2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "LIMS2::Schema::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-12-07 10:44:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V62gwUw5Yps4wdZiTBURZA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
