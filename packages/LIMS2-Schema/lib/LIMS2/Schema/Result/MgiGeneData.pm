use utf8;
package LIMS2::Schema::Result::MgiGeneData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::MgiGeneData

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

=head1 TABLE: C<mgi_gene_data>

=cut

__PACKAGE__->table("mgi_gene_data");

=head1 ACCESSORS

=head2 mgi_accession_id

  data_type: 'text'
  is_nullable: 0

=head2 marker_type

  data_type: 'text'
  is_nullable: 1

=head2 marker_symbol

  data_type: 'text'
  is_nullable: 1

=head2 marker_name

  data_type: 'text'
  is_nullable: 1

=head2 representative_genome_id

  data_type: 'text'
  is_nullable: 1

=head2 representative_genome_chr

  data_type: 'text'
  is_nullable: 1

=head2 representative_genome_start

  data_type: 'integer'
  is_nullable: 1

=head2 representative_genome_end

  data_type: 'integer'
  is_nullable: 1

=head2 representative_genome_strand

  data_type: 'integer'
  is_nullable: 1

=head2 representative_genome_build

  data_type: 'text'
  is_nullable: 1

=head2 entrez_gene_id

  data_type: 'text'
  is_nullable: 1

=head2 ncbi_gene_chromosome

  data_type: 'text'
  is_nullable: 1

=head2 ncbi_gene_start

  data_type: 'integer'
  is_nullable: 1

=head2 ncbi_gene_end

  data_type: 'integer'
  is_nullable: 1

=head2 ncbi_gene_strand

  data_type: 'integer'
  is_nullable: 1

=head2 unists_gene_chromosome

  data_type: 'text'
  is_nullable: 1

=head2 unists_gene_start

  data_type: 'integer'
  is_nullable: 1

=head2 unists_gene_end

  data_type: 'integer'
  is_nullable: 1

=head2 mgi_qtl_gene_chromosome

  data_type: 'text'
  is_nullable: 1

=head2 mgi_qtl_gene_start

  data_type: 'integer'
  is_nullable: 1

=head2 mgi_qtl_gene_end

  data_type: 'integer'
  is_nullable: 1

=head2 mirbase_gene_id

  data_type: 'text'
  is_nullable: 1

=head2 mirbase_gene_chromosome

  data_type: 'text'
  is_nullable: 1

=head2 mirbase_gene_start

  data_type: 'integer'
  is_nullable: 1

=head2 mirbase_gene_end

  data_type: 'integer'
  is_nullable: 1

=head2 mirbase_gene_strand

  data_type: 'integer'
  is_nullable: 1

=head2 roopenian_sts_gene_start

  data_type: 'integer'
  is_nullable: 1

=head2 roopenian_sts_gene_end

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "mgi_accession_id",
  { data_type => "text", is_nullable => 0 },
  "marker_type",
  { data_type => "text", is_nullable => 1 },
  "marker_symbol",
  { data_type => "text", is_nullable => 1 },
  "marker_name",
  { data_type => "text", is_nullable => 1 },
  "representative_genome_id",
  { data_type => "text", is_nullable => 1 },
  "representative_genome_chr",
  { data_type => "text", is_nullable => 1 },
  "representative_genome_start",
  { data_type => "integer", is_nullable => 1 },
  "representative_genome_end",
  { data_type => "integer", is_nullable => 1 },
  "representative_genome_strand",
  { data_type => "integer", is_nullable => 1 },
  "representative_genome_build",
  { data_type => "text", is_nullable => 1 },
  "entrez_gene_id",
  { data_type => "text", is_nullable => 1 },
  "ncbi_gene_chromosome",
  { data_type => "text", is_nullable => 1 },
  "ncbi_gene_start",
  { data_type => "integer", is_nullable => 1 },
  "ncbi_gene_end",
  { data_type => "integer", is_nullable => 1 },
  "ncbi_gene_strand",
  { data_type => "integer", is_nullable => 1 },
  "unists_gene_chromosome",
  { data_type => "text", is_nullable => 1 },
  "unists_gene_start",
  { data_type => "integer", is_nullable => 1 },
  "unists_gene_end",
  { data_type => "integer", is_nullable => 1 },
  "mgi_qtl_gene_chromosome",
  { data_type => "text", is_nullable => 1 },
  "mgi_qtl_gene_start",
  { data_type => "integer", is_nullable => 1 },
  "mgi_qtl_gene_end",
  { data_type => "integer", is_nullable => 1 },
  "mirbase_gene_id",
  { data_type => "text", is_nullable => 1 },
  "mirbase_gene_chromosome",
  { data_type => "text", is_nullable => 1 },
  "mirbase_gene_start",
  { data_type => "integer", is_nullable => 1 },
  "mirbase_gene_end",
  { data_type => "integer", is_nullable => 1 },
  "mirbase_gene_strand",
  { data_type => "integer", is_nullable => 1 },
  "roopenian_sts_gene_start",
  { data_type => "integer", is_nullable => 1 },
  "roopenian_sts_gene_end",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</mgi_accession_id>

=back

=cut

__PACKAGE__->set_primary_key("mgi_accession_id");

=head1 RELATIONS

=head2 mgi_ensembl_gene_maps

Type: has_many

Related object: L<LIMS2::Schema::Result::MgiEnsemblGeneMap>

=cut

__PACKAGE__->has_many(
  "mgi_ensembl_gene_maps",
  "LIMS2::Schema::Result::MgiEnsemblGeneMap",
  { "foreign.mgi_accession_id" => "self.mgi_accession_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 mgi_vega_gene_maps

Type: has_many

Related object: L<LIMS2::Schema::Result::MgiVegaGeneMap>

=cut

__PACKAGE__->has_many(
  "mgi_vega_gene_maps",
  "LIMS2::Schema::Result::MgiVegaGeneMap",
  { "foreign.mgi_accession_id" => "self.mgi_accession_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07012 @ 2011-11-17 11:35:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B7oN8yWB12r5EnqCNRpE7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
