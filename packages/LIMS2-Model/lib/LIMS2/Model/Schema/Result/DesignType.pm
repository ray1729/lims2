use utf8;
package LIMS2::Model::Schema::Result::DesignType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::DesignType

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

=head1 TABLE: C<design_types>

=cut

__PACKAGE__->table("design_types");

=head1 ACCESSORS

=head2 design_type

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("design_type", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</design_type>

=back

=cut

__PACKAGE__->set_primary_key("design_type");

=head1 RELATIONS

=head2 designs

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::Design>

=cut

__PACKAGE__->has_many(
  "designs",
  "LIMS2::Model::Schema::Result::Design",
  { "foreign.design_type" => "self.design_type" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-05 09:46:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XZ2XiWV6WZxXg2KRLHVJBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
