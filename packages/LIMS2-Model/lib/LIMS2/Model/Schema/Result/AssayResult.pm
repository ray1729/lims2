use utf8;
package LIMS2::Model::Schema::Result::AssayResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::AssayResult

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

=head1 TABLE: C<assay_result>

=cut

__PACKAGE__->table("assay_result");

=head1 ACCESSORS

=head2 assay

  data_type: 'text'
  is_nullable: 0

=head2 result

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "assay",
  { data_type => "text", is_nullable => 0 },
  "result",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</assay>

=item * L</result>

=back

=cut

__PACKAGE__->set_primary_key("assay", "result");

=head1 RELATIONS

=head2 well_assay_results

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::WellAssayResult>

=cut

__PACKAGE__->has_many(
  "well_assay_results",
  "LIMS2::Model::Schema::Result::WellAssayResult",
  { "foreign.assay" => "self.assay", "foreign.result" => "self.result" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-18 11:04:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bB25qOpbOGI6g2On6QkOKA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
