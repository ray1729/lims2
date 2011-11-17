use utf8;
package LIMS2::Schema::Result::MgiVegaGeneMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::MgiVegaGeneMap

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

=head1 TABLE: C<mgi_vega_gene_map>

=cut

__PACKAGE__->table("mgi_vega_gene_map");

=head1 ACCESSORS

=head2 mgi_accession_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 vega_gene_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "mgi_accession_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "vega_gene_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</mgi_accession_id>

=item * L</vega_gene_id>

=back

=cut

__PACKAGE__->set_primary_key("mgi_accession_id", "vega_gene_id");

=head1 RELATIONS

=head2 mgi_accession

Type: belongs_to

Related object: L<LIMS2::Schema::Result::MgiGeneData>

=cut

__PACKAGE__->belongs_to(
  "mgi_accession",
  "LIMS2::Schema::Result::MgiGeneData",
  { mgi_accession_id => "mgi_accession_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 vega_gene

Type: belongs_to

Related object: L<LIMS2::Schema::Result::VegaGeneData>

=cut

__PACKAGE__->belongs_to(
  "vega_gene",
  "LIMS2::Schema::Result::VegaGeneData",
  { vega_gene_id => "vega_gene_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07012 @ 2011-11-17 11:35:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:23cZ37HXgXD83lTx6j4H+g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
