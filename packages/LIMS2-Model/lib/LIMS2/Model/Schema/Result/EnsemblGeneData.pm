use utf8;
package LIMS2::Model::Schema::Result::EnsemblGeneData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::EnsemblGeneData

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

=head1 TABLE: C<ensembl_gene_data>

=cut

__PACKAGE__->table("ensembl_gene_data");

=head1 ACCESSORS

=head2 ensembl_gene_id

  data_type: 'text'
  is_nullable: 0

=head2 ensembl_gene_chromosome

  data_type: 'text'
  is_nullable: 0

=head2 ensembl_gene_start

  data_type: 'integer'
  is_nullable: 0

=head2 ensembl_gene_end

  data_type: 'integer'
  is_nullable: 0

=head2 ensembl_gene_strand

  data_type: 'integer'
  is_nullable: 0

=head2 sp

  data_type: 'boolean'
  is_nullable: 0

=head2 tm

  data_type: 'boolean'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ensembl_gene_id",
  { data_type => "text", is_nullable => 0 },
  "ensembl_gene_chromosome",
  { data_type => "text", is_nullable => 0 },
  "ensembl_gene_start",
  { data_type => "integer", is_nullable => 0 },
  "ensembl_gene_end",
  { data_type => "integer", is_nullable => 0 },
  "ensembl_gene_strand",
  { data_type => "integer", is_nullable => 0 },
  "sp",
  { data_type => "boolean", is_nullable => 0 },
  "tm",
  { data_type => "boolean", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</ensembl_gene_id>

=back

=cut

__PACKAGE__->set_primary_key("ensembl_gene_id");

=head1 RELATIONS

=head2 mgi_ensembl_gene_maps

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::MgiEnsemblGeneMap>

=cut

__PACKAGE__->has_many(
  "mgi_ensembl_gene_maps",
  "LIMS2::Model::Schema::Result::MgiEnsemblGeneMap",
  { "foreign.ensembl_gene_id" => "self.ensembl_gene_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-05 09:46:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Aro6QiASyjoFBHVjJPSP/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
