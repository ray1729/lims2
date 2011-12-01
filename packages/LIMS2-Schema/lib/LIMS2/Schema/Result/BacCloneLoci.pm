use utf8;
package LIMS2::Schema::Result::BacCloneLoci;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::BacCloneLoci

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

=head1 TABLE: C<bac_clone_loci>

=cut

__PACKAGE__->table("bac_clone_loci");

=head1 ACCESSORS

=head2 bac_clone_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 assembly

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 chromosome

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 bac_start

  data_type: 'integer'
  is_nullable: 0

=head2 bac_end

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "bac_clone_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "assembly",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "chromosome",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "bac_start",
  { data_type => "integer", is_nullable => 0 },
  "bac_end",
  { data_type => "integer", is_nullable => 0 },
);

=head1 RELATIONS

=head2 assembly

Type: belongs_to

Related object: L<LIMS2::Schema::Result::Assembly>

=cut

__PACKAGE__->belongs_to(
  "assembly",
  "LIMS2::Schema::Result::Assembly",
  { assembly => "assembly" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 bac_clone

Type: belongs_to

Related object: L<LIMS2::Schema::Result::BacClone>

=cut

__PACKAGE__->belongs_to(
  "bac_clone",
  "LIMS2::Schema::Result::BacClone",
  { bac_clone_id => "bac_clone_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 chromosome

Type: belongs_to

Related object: L<LIMS2::Schema::Result::Chromosome>

=cut

__PACKAGE__->belongs_to(
  "chromosome",
  "LIMS2::Schema::Result::Chromosome",
  { chromosome => "chromosome" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-12-01 12:57:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UjBKL7YyhOlOENAKAbXdgA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
