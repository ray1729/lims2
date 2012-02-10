use utf8;
package LIMS2::Model::Schema::Result::ProcessCreateDiBac;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::ProcessCreateDiBac

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

=head1 TABLE: C<process_create_di_bacs>

=cut

__PACKAGE__->table("process_create_di_bacs");

=head1 ACCESSORS

=head2 process_id

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
  "process_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "bac_plate",
  { data_type => "text", is_nullable => 0 },
  "bac_library",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "bac_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<process_create_di_bacs_process_id_bac_plate_key>

=over 4

=item * L</process_id>

=item * L</bac_plate>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "process_create_di_bacs_process_id_bac_plate_key",
  ["process_id", "bac_plate"],
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

=head2 process

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::ProcessCreateDi>

=cut

__PACKAGE__->belongs_to(
  "process",
  "LIMS2::Model::Schema::Result::ProcessCreateDi",
  { process_id => "process_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-02-10 15:16:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uTKajLSWqy6suqbgU2WkLg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
