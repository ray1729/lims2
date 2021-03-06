use utf8;
package LIMS2::Model::Schema::Result::DesignComment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::DesignComment

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

=head1 TABLE: C<design_comments>

=cut

__PACKAGE__->table("design_comments");

=head1 ACCESSORS

=head2 design_comment_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'design_comments_design_comment_id_seq'

=head2 design_comment_category_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 design_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 design_comment

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 is_public

  data_type: 'boolean'
  default_value: false
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
  "design_comment_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "design_comments_design_comment_id_seq",
  },
  "design_comment_category_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "design_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "design_comment",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "is_public",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
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

=item * L</design_comment_id>

=back

=cut

__PACKAGE__->set_primary_key("design_comment_id");

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

=head2 design

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::Design>

=cut

__PACKAGE__->belongs_to(
  "design",
  "LIMS2::Model::Schema::Result::Design",
  { design_id => "design_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 design_comment_category

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::DesignCommentCategory>

=cut

__PACKAGE__->belongs_to(
  "design_comment_category",
  "LIMS2::Model::Schema::Result::DesignCommentCategory",
  { design_comment_category_id => "design_comment_category_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-09 16:47:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WZVS2c7F02CJq5G0I819aA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub as_hash {
    my $self = shift;

    return {
        design_comment_category => $self->design_comment_category->design_comment_category,
        design_comment          => $self->design_comment,
        is_public               => $self->is_public,
        created_by              => $self->created_by->user_name,
        created_at              => $self->created_at->iso8601            
    };
}

__PACKAGE__->meta->make_immutable;
1;
