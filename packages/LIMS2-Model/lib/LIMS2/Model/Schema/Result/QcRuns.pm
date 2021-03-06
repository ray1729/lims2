use utf8;
package LIMS2::Model::Schema::Result::QcRuns;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::QcRuns

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

=head1 TABLE: C<qc_runs>

=cut

__PACKAGE__->table("qc_runs");

=head1 ACCESSORS

=head2 qc_run_id

  data_type: 'char'
  is_nullable: 0
  size: 36

=head2 qc_run_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 sequencing_project

  data_type: 'text'
  is_nullable: 0

=head2 profile

  data_type: 'text'
  is_nullable: 0

=head2 qc_template_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 software_version

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "qc_run_id",
  { data_type => "char", is_nullable => 0, size => 36 },
  "qc_run_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "sequencing_project",
  { data_type => "text", is_nullable => 0 },
  "profile",
  { data_type => "text", is_nullable => 0 },
  "qc_template_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "software_version",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</qc_run_id>

=back

=cut

__PACKAGE__->set_primary_key("qc_run_id");

=head1 RELATIONS

=head2 qc_run_sequencing_projects

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcRunSequencingProject>

=cut

__PACKAGE__->has_many(
  "qc_run_sequencing_projects",
  "LIMS2::Model::Schema::Result::QcRunSequencingProject",
  { "foreign.qc_run_id" => "self.qc_run_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 qc_template

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::QcTemplate>

=cut

__PACKAGE__->belongs_to(
  "qc_template",
  "LIMS2::Model::Schema::Result::QcTemplate",
  { qc_template_id => "qc_template_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 qc_test_results

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcTestResult>

=cut

__PACKAGE__->has_many(
  "qc_test_results",
  "LIMS2::Model::Schema::Result::QcTestResult",
  { "foreign.qc_run_id" => "self.qc_run_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-03-28 13:04:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gkdNEShVyPLa2hje5n2odA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
