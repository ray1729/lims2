use utf8;
package LIMS2::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::Role

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

=head1 TABLE: C<roles>

=cut

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'roles_role_id_seq'

=head2 role_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "role_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "roles_role_id_seq",
  },
  "role_name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<roles_role_name_key>

=over 4

=item * L</role_name>

=back

=cut

__PACKAGE__->add_unique_constraint("roles_role_name_key", ["role_name"]);

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<LIMS2::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "LIMS2::Schema::Result::UserRole",
  { "foreign.role_id" => "self.role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07012 @ 2011-11-17 11:35:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9PB4GkFE6mZUTumfQFaxNA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->many_to_many( 'users' => 'user_roles' => 'user' );

__PACKAGE__->meta->make_immutable;
1;
