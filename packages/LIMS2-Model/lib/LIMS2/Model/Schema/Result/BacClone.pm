use utf8;
package LIMS2::Model::Schema::Result::BacClone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LIMS2::Model::Schema::Result::BacClone

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

=head1 TABLE: C<bac_clones>

=cut

__PACKAGE__->table("bac_clones");

=head1 ACCESSORS

=head2 bac_name

  data_type: 'text'
  is_nullable: 0

=head2 bac_library

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "bac_name",
  { data_type => "text", is_nullable => 0 },
  "bac_library",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bac_name>

=item * L</bac_library>

=back

=cut

__PACKAGE__->set_primary_key("bac_name", "bac_library");

=head1 RELATIONS

=head2 bac_library_rel

Type: belongs_to

Related object: L<LIMS2::Model::Schema::Result::BacLibrary>

=cut

__PACKAGE__->belongs_to(
  "bac_library_rel",
  "LIMS2::Model::Schema::Result::BacLibrary",
  { bac_library => "bac_library" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 loci

Type: has_many

Related object: L<LIMS2::Model::Schema::Result::BacCloneLocus>

=cut

__PACKAGE__->has_many(
  "loci",
  "LIMS2::Model::Schema::Result::BacCloneLocus",
  {
    "foreign.bac_library" => "self.bac_library",
    "foreign.bac_name"    => "self.bac_name",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07014 @ 2012-01-09 16:33:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FY6h1IRZYANetKX4yX2WPA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub as_hash {
    my $self = shift;

    return {
        bac_library => $self->bac_library,
        bac_name    => $self->bac_name,
        loci        => [ map { $_->as_hash } $self->loci ],
    };
}

__PACKAGE__->meta->make_immutable;
1;
