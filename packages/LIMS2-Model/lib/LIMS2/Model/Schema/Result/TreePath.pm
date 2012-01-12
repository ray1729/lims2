use utf8;
package LIMS2::Model::Schema::Result::TreePath;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::TreePath

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

=head1 TABLE: C<tree_paths>

=cut

__PACKAGE__->table("tree_paths");

=head1 ACCESSORS

=head2 ancestor

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 descendant

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 path_length

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ancestor",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "descendant",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "path_length",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ancestor>

=item * L</descendant>

=back

=cut

__PACKAGE__->set_primary_key("ancestor", "descendant");

=head1 RELATIONS

=head2 ancestor

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Well>

=cut

__PACKAGE__->belongs_to(
  "ancestor",
  "LIMS2::Model::Schema::Result::Well",
  { well_id => "ancestor" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 descendant

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Well>

=cut

__PACKAGE__->belongs_to(
  "descendant",
  "LIMS2::Model::Schema::Result::Well",
  { well_id => "descendant" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-12 13:54:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KZ0Cl3t33pPNSm1R8HaUmg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
