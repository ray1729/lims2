use utf8;
package LIMS2::Model::Schema::Result::Pipeline;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::Pipeline

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

=head1 TABLE: C<pipelines>

=cut

__PACKAGE__->table("pipelines");

=head1 ACCESSORS

=head2 pipeline_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'pipelines_pipeline_id_seq'

=head2 pipeline_name

  data_type: 'text'
  is_nullable: 1

=head2 pipeline_desc

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "pipeline_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "pipelines_pipeline_id_seq",
  },
  "pipeline_name",
  { data_type => "text", is_nullable => 1 },
  "pipeline_desc",
  { data_type => "text", default_value => "", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</pipeline_id>

=back

=cut

__PACKAGE__->set_primary_key("pipeline_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<pipelines_pipeline_name_key>

=over 4

=item * L</pipeline_name>

=back

=cut

__PACKAGE__->add_unique_constraint("pipelines_pipeline_name_key", ["pipeline_name"]);

=head1 RELATIONS

=head2 process_pipelines

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::ProcessPipeline>

=cut

__PACKAGE__->has_many(
  "process_pipelines",
  "LIMS2::Model::Schema::Result::ProcessPipeline",
  { "foreign.pipeline_id" => "self.pipeline_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-02-10 15:16:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dPYnrfmgRR7p30aP542irA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
