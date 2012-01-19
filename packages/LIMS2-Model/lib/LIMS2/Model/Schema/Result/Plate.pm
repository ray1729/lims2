use utf8;
package LIMS2::Model::Schema::Result::Plate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::Plate

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

=head1 TABLE: C<plates>

=cut

__PACKAGE__->table("plates");

=head1 ACCESSORS

=head2 plate_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'plates_plate_id_seq'

=head2 plate_name

  data_type: 'text'
  is_nullable: 0

=head2 plate_type

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 plate_desc

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 created_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "plate_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "plates_plate_id_seq",
  },
  "plate_name",
  { data_type => "text", is_nullable => 0 },
  "plate_type",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "plate_desc",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "created_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</plate_id>

=back

=cut

__PACKAGE__->set_primary_key("plate_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<plates_plate_name_key>

=over 4

=item * L</plate_name>

=back

=cut

__PACKAGE__->add_unique_constraint("plates_plate_name_key", ["plate_name"]);

=head1 RELATIONS

=head2 created_by

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "created_by",
  "LIMS2::Model::Schema::Result::User",
  { user_id => "created_by" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 plate_comments

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::PlateComment>

=cut

__PACKAGE__->has_many(
  "plate_comments",
  "LIMS2::Model::Schema::Result::PlateComment",
  { "foreign.plate_id" => "self.plate_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 plate_type_rel

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::PlateType>

=cut

__PACKAGE__->belongs_to(
  "plate_type_rel",
  "LIMS2::Model::Schema::Result::PlateType",
  { plate_type => "plate_type" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 wells

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::Well>

=cut

__PACKAGE__->has_many(
  "wells",
  "LIMS2::Model::Schema::Result::Well",
  { "foreign.plate_id" => "self.plate_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-19 15:28:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ChQoXrEhHs5JJly9GbFMXQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub as_hash {
    my $self = shift;

    return {
        plate_name => $self->plate_name,
        plate_type => $self->plate_type,
        plate_desc => $self->plate_desc,
        created_at => $self->created_at->iso8601,
        created_by => $self->created_by->user_name,
        comments   => [ map { $_->as_hash } $self->plate_comments ]
    };
}        

__PACKAGE__->meta->make_immutable;
1;
