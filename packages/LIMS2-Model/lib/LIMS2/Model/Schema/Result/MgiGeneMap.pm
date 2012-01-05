use utf8;
package LIMS2::Model::Schema::Result::MgiGeneMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::MgiGeneMap

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

=head1 TABLE: C<mgi_gene_map>

=cut

__PACKAGE__->table("mgi_gene_map");

=head1 ACCESSORS

=head2 gene_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 mgi_accession_id

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "gene_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "mgi_accession_id",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</gene_id>

=item * L</mgi_accession_id>

=back

=cut

__PACKAGE__->set_primary_key("gene_id", "mgi_accession_id");

=head1 RELATIONS

=head2 gene

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Gene>

=cut

__PACKAGE__->belongs_to(
  "gene",
  "LIMS2::Model::Schema::Result::Gene",
  { gene_id => "gene_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-05 09:46:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4+W5nZSvMEVVFXqpn+MNcw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
