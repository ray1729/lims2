use utf8;
package LIMS2::Model::Schema::Result::BacCloneLocus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::BacCloneLocus

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

=head2 bac_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 bac_library

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 assembly

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 chr_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 chr_start

  data_type: 'integer'
  is_nullable: 0

=head2 chr_end

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "bac_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "bac_library",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "assembly",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "chr_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "chr_start",
  { data_type => "integer", is_nullable => 0 },
  "chr_end",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bac_name>

=item * L</bac_library>

=item * L</assembly>

=back

=cut

__PACKAGE__->set_primary_key("bac_name", "bac_library", "assembly");

=head1 RELATIONS

=head2 assembly_rel

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Assembly>

=cut

__PACKAGE__->belongs_to(
  "assembly_rel",
  "LIMS2::Model::Schema::Result::Assembly",
  { assembly => "assembly" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

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

=head2 chromosome

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Chromosome>

=cut

__PACKAGE__->belongs_to(
  "chromosome",
  "LIMS2::Model::Schema::Result::Chromosome",
  { chromosome => "chr_name" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-09 16:35:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qVIfHtGDz0RslP7wyeLXvA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub as_hash {
    my $self = shift;

    return {
        assembly   => $self->assembly,
        chr_name   => $self->chr_name,
        chr_start  => $self->bac_start,
        chr_end    => $self->bac_end
    };
}

__PACKAGE__->meta->make_immutable;
1;
