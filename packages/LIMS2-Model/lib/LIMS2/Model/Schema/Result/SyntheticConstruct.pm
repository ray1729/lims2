use utf8;
package LIMS2::Model::Schema::Result::SyntheticConstruct;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::SyntheticConstruct

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

=head1 TABLE: C<synthetic_constructs>

=cut

__PACKAGE__->table("synthetic_constructs");

=head1 ACCESSORS

=head2 synthetic_construct_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'synthetic_constructs_synthetic_construct_id_seq'

=head2 synthetic_construct_genbank

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "synthetic_construct_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "synthetic_constructs_synthetic_construct_id_seq",
  },
  "synthetic_construct_genbank",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</synthetic_construct_id>

=back

=cut

__PACKAGE__->set_primary_key("synthetic_construct_id");

=head1 RELATIONS

=head2 process_synthetics_construct

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::ProcessSyntheticConstruct>

=cut

__PACKAGE__->has_many(
  "process_synthetics_construct",
  "LIMS2::Model::Schema::Result::ProcessSyntheticConstruct",
  {
    "foreign.synthetic_construct_id" => "self.synthetic_construct_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 qc_test_results

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::QcTestResult>

=cut

__PACKAGE__->has_many(
  "qc_test_results",
  "LIMS2::Model::Schema::Result::QcTestResult",
  {
    "foreign.synthetic_construct_id" => "self.synthetic_construct_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-02-10 15:16:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y3yNhTjbvGB/+RqCcnZCtw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
