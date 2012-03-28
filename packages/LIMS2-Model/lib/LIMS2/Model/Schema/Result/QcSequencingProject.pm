use utf8;
package LIMS2::Model::Schema::Result::QcSequencingProject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::QcSequencingProject

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

=head1 TABLE: C<qc_sequencing_projects>

=cut

__PACKAGE__->table("qc_sequencing_projects");

=head1 ACCESSORS

=head2 qc_sequencing_project

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "qc_sequencing_project",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</qc_sequencing_project>

=back

=cut

__PACKAGE__->set_primary_key("qc_sequencing_project");

=head1 RELATIONS

=head2 qc_run_sequencing_projects

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcRunSequencingProject>

=cut

__PACKAGE__->has_many(
  "qc_run_sequencing_projects",
  "LIMS2::Model::Schema::Result::QcRunSequencingProject",
  { "foreign.qc_sequencing_project" => "self.qc_sequencing_project" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 qc_seqs_reads

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcSeqRead>

=cut

__PACKAGE__->has_many(
  "qc_seqs_reads",
  "LIMS2::Model::Schema::Result::QcSeqRead",
  { "foreign.qc_sequencing_project" => "self.qc_sequencing_project" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-03-28 13:04:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UJYF0moSxlhJSWZQ+INUWQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
