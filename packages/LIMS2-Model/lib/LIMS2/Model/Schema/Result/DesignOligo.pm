use utf8;
package LIMS2::Model::Schema::Result::DesignOligo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::DesignOligo

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

=head1 TABLE: C<design_oligos>

=cut

__PACKAGE__->table("design_oligos");

=head1 ACCESSORS

=head2 design_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 design_oligo_type

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 design_oligo_seq

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "design_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "design_oligo_type",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "design_oligo_seq",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</design_id>

=item * L</design_oligo_type>

=back

=cut

__PACKAGE__->set_primary_key("design_id", "design_oligo_type");

=head1 RELATIONS

=head2 design

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Design>

=cut

__PACKAGE__->belongs_to(
  "design",
  "LIMS2::Model::Schema::Result::Design",
  { design_id => "design_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 design_oligo_type

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::DesignOligoType>

=cut

__PACKAGE__->belongs_to(
  "design_oligo_type",
  "LIMS2::Model::Schema::Result::DesignOligoType",
  { design_oligo_type => "design_oligo_type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 loci

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::DesignOligoLocus>

=cut

__PACKAGE__->has_many(
  "loci",
  "LIMS2::Model::Schema::Result::DesignOligoLocus",
  {
    "foreign.design_id"         => "self.design_id",
    "foreign.design_oligo_type" => "self.design_oligo_type",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-05 09:46:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nKtmFy30ttyV/tcoJk/V+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
