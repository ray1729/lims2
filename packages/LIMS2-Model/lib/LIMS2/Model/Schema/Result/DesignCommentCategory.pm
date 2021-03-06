use utf8;
package LIMS2::Model::Schema::Result::DesignCommentCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::DesignCommentCategory

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

=head1 TABLE: C<design_comment_categories>

=cut

__PACKAGE__->table("design_comment_categories");

=head1 ACCESSORS

=head2 design_comment_category_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'design_comment_categories_design_comment_category_id_seq'

=head2 design_comment_category

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "design_comment_category_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "design_comment_categories_design_comment_category_id_seq",
  },
  "design_comment_category",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</design_comment_category_id>

=back

=cut

__PACKAGE__->set_primary_key("design_comment_category_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<design_comment_categories_design_comment_category_key>

=over 4

=item * L</design_comment_category>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "design_comment_categories_design_comment_category_key",
  ["design_comment_category"],
);

=head1 RELATIONS

=head2 design_comments

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::DesignComment>

=cut

__PACKAGE__->has_many(
  "design_comments",
  "LIMS2::Model::Schema::Result::DesignComment",
  {
    "foreign.design_comment_category_id" => "self.design_comment_category_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-02-10 15:16:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C/QNUoWsFfiElhRYo8hXRA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
