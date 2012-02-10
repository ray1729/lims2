use utf8;
package LIMS2::Model::Schema::Result::QcTemplate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::QcTemplate

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

=head1 TABLE: C<qc_templates>

=cut

__PACKAGE__->table("qc_templates");

=head1 ACCESSORS

=head2 qc_template_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'qc_templates_qc_template_id_seq'

=head2 qc_template_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "qc_template_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "qc_templates_qc_template_id_seq",
  },
  "qc_template_name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</qc_template_id>

=back

=cut

__PACKAGE__->set_primary_key("qc_template_id");

=head1 RELATIONS

=head2 qc_template_wells

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcTemplateWell>

=cut

__PACKAGE__->has_many(
  "qc_template_wells",
  "LIMS2::Model::Schema::Result::QcTemplateWell",
  { "foreign.qc_template_id" => "self.qc_template_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 qcs_runs

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcRuns>

=cut

__PACKAGE__->has_many(
  "qcs_runs",
  "LIMS2::Model::Schema::Result::QcRuns",
  { "foreign.qc_template_id" => "self.qc_template_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-02-10 15:16:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:opnLiWQ8hIN6jCTBXwOfIA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
