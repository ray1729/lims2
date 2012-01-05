use utf8;
package LIMS2::Model::Schema::Result::Gene;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::Gene

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

=head1 TABLE: C<genes>

=cut

__PACKAGE__->table("genes");

=head1 ACCESSORS

=head2 gene_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'genes_gene_id_seq'

=cut

__PACKAGE__->add_columns(
  "gene_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "genes_gene_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</gene_id>

=back

=cut

__PACKAGE__->set_primary_key("gene_id");

=head1 RELATIONS

=head2 gene_comments

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::GeneComment>

=cut

__PACKAGE__->has_many(
  "gene_comments",
  "LIMS2::Model::Schema::Result::GeneComment",
  { "foreign.gene_id" => "self.gene_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 mgi_gene_maps

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::MgiGeneMap>

=cut

__PACKAGE__->has_many(
  "mgi_gene_maps",
  "LIMS2::Model::Schema::Result::MgiGeneMap",
  { "foreign.gene_id" => "self.gene_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-05 09:46:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gJvrJk+qRW5Iedv0Q2MLoQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
