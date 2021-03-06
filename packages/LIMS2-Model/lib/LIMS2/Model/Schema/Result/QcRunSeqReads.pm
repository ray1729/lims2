use utf8;
package LIMS2::Model::Schema::Result::QcRunSeqReads;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::QcRunSeqReads

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

=head1 TABLE: C<qc_run_seq_reads>

=cut

__PACKAGE__->table("qc_run_seq_reads");

=head1 ACCESSORS

=head2 qc_run_id

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 36

=head2 qc_seq_read_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "qc_run_id",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 36 },
  "qc_seq_read_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</qc_run_id>

=item * L</qc_seq_read_id>

=back

=cut

__PACKAGE__->set_primary_key("qc_run_id", "qc_seq_read_id");

=head1 RELATIONS

=head2 qc_run

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::QcRuns>

=cut

__PACKAGE__->belongs_to(
  "qc_run",
  "LIMS2::Model::Schema::Result::QcRuns",
  { qc_run_id => "qc_run_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 qc_seq_read

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::QcSeqRead>

=cut

__PACKAGE__->belongs_to(
  "qc_seq_read",
  "LIMS2::Model::Schema::Result::QcSeqRead",
  { qc_seq_read_id => "qc_seq_read_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-03-13 14:17:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mZla2dpJB1AwObbid3L30A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
