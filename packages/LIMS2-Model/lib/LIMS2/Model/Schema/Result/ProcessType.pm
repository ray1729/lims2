use utf8;
package LIMS2::Model::Schema::Result::ProcessType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::ProcessType

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

=head1 TABLE: C<process_types>

=cut

__PACKAGE__->table("process_types");

=head1 ACCESSORS

=head2 process_type

  data_type: 'text'
  is_nullable: 0

=head2 process_description

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "process_type",
  { data_type => "text", is_nullable => 0 },
  "process_description",
  { data_type => "text", default_value => "", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</process_type>

=back

=cut

__PACKAGE__->set_primary_key("process_type");

=head1 RELATIONS

=head2 processes

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::Process>

=cut

__PACKAGE__->has_many(
  "processes",
  "LIMS2::Model::Schema::Result::Process",
  { "foreign.process_type" => "self.process_type" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-02-10 15:16:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CaphQVG/otvlIGHNfr7BbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
