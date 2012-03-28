use utf8;
package LIMS2::Model::Schema::Result::Process;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::Process

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

=head1 TABLE: C<processes>

=cut

__PACKAGE__->table("processes");

=head1 ACCESSORS

=head2 process_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'processes_process_id_seq'

=head2 process_type

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "process_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "processes_process_id_seq",
  },
  "process_type",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</process_id>

=back

=cut

__PACKAGE__->set_primary_key("process_id");

=head1 RELATIONS

=head2 process_2w_gateway

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::Process2wGateway>

=cut

__PACKAGE__->might_have(
  "process_2w_gateway",
  "LIMS2::Model::Schema::Result::Process2wGateway",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_3w_gateway

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::Process3wGateway>

=cut

__PACKAGE__->might_have(
  "process_3w_gateway",
  "LIMS2::Model::Schema::Result::Process3wGateway",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_cre_bac_recom

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::ProcessCreBacRecom>

=cut

__PACKAGE__->might_have(
  "process_cre_bac_recom",
  "LIMS2::Model::Schema::Result::ProcessCreBacRecom",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_create_di

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::ProcessCreateDi>

=cut

__PACKAGE__->might_have(
  "process_create_di",
  "LIMS2::Model::Schema::Result::ProcessCreateDi",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_int_recom

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::ProcessIntRecom>

=cut

__PACKAGE__->might_have(
  "process_int_recom",
  "LIMS2::Model::Schema::Result::ProcessIntRecom",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_pipeline

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::ProcessPipeline>

=cut

__PACKAGE__->might_have(
  "process_pipeline",
  "LIMS2::Model::Schema::Result::ProcessPipeline",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_rearray

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::ProcessRearray>

=cut

__PACKAGE__->might_have(
  "process_rearray",
  "LIMS2::Model::Schema::Result::ProcessRearray",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_synthetic_construct

Type: might_have

Related object: L<LIMS2::Model::Schema::Result::ProcessSyntheticConstruct>

=cut

__PACKAGE__->might_have(
  "process_synthetic_construct",
  "LIMS2::Model::Schema::Result::ProcessSyntheticConstruct",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 process_type

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::ProcessType>

=cut

__PACKAGE__->belongs_to(
  "process_type",
  "LIMS2::Model::Schema::Result::ProcessType",
  { process_type => "process_type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 wells

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::Well>

=cut

__PACKAGE__->has_many(
  "wells",
  "LIMS2::Model::Schema::Result::Well",
  { "foreign.process_id" => "self.process_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-03-28 13:04:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C1O2ywmnb4HaDTVelNjnCw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

with qw( LIMS2::Model::Schema::Extensions::Process );

__PACKAGE__->meta->make_immutable;
1;
