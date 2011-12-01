use utf8;
package LIMS2::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_user_id_seq'

=head2 user_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_user_id_seq",
  },
  "user_name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<users_user_name_key>

=over 4

=item * L</user_name>

=back

=cut

__PACKAGE__->add_unique_constraint("users_user_name_key", ["user_name"]);

=head1 RELATIONS

=head2 design_comments

Type: has_many

Related object: L<LIMS2::Schema::Result::DesignComment>

=cut

__PACKAGE__->has_many(
  "design_comments",
  "LIMS2::Schema::Result::DesignComment",
  { "foreign.created_by" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 designs

Type: has_many

Related object: L<LIMS2::Schema::Result::Design>

=cut

__PACKAGE__->has_many(
  "designs",
  "LIMS2::Schema::Result::Design",
  { "foreign.created_user" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_comments

Type: has_many

Related object: L<LIMS2::Schema::Result::GeneComment>

=cut

__PACKAGE__->has_many(
  "gene_comments",
  "LIMS2::Schema::Result::GeneComment",
  { "foreign.created_by" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<LIMS2::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "LIMS2::Schema::Result::UserRole",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-12-01 12:56:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RHXQC9gsNSEiAwHsj+2m1Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->many_to_many( 'roles' => 'user_roles' => 'role' );

__PACKAGE__->meta->make_immutable;
1;
