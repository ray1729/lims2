use utf8;
package LIMS2::Model::Schema::Result::DesignWellBac;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::DesignWellBac

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

=head1 TABLE: C<design_well_bac>

=cut

__PACKAGE__->table("design_well_bac");

=head1 ACCESSORS

=head2 well_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 bac_plate

  data_type: 'text'
  is_nullable: 0

=head2 bac_library

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 bac_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "well_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "bac_plate",
  { data_type => "text", is_nullable => 0 },
  "bac_library",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "bac_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<design_well_bac_well_id_bac_plate_key>

=over 4

=item * L</well_id>

=item * L</bac_plate>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "design_well_bac_well_id_bac_plate_key",
  ["well_id", "bac_plate"],
);

=head1 RELATIONS

=head2 bac_clone

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::BacClone>

=cut

__PACKAGE__->belongs_to(
  "bac_clone",
  "LIMS2::Model::Schema::Result::BacClone",
  { bac_library => "bac_library", bac_name => "bac_name" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 well

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Well>

=cut

__PACKAGE__->belongs_to(
  "well",
  "LIMS2::Model::Schema::Result::Well",
  { well_id => "well_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-12 13:54:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jaJWzmLTjQsCzEiAZEiiGg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
