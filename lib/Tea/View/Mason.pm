=head1 NAME
Tea::View::Mason - Mason View Component for SGN
=head1 DESCRIPTION
Mason View Component for TEA. This extends Catalyst::View::HTML::Mason.
=cut


package Tea::View::Mason;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

extends 'Catalyst::View::HTML::Mason';
with 'Catalyst::Component::ApplicationAttribute';

# use Catalyst qw/$c /;

__PACKAGE__->config(
    globals => ['$c'],
    template_extension => '.mas',
    interp_args => {
        # data_dir => Tea->tempfiles_base->subdir('mason'),
        comp_root => [
            [ main => Tea->path_to('mason') ],
        ],
    },
);


=head1 CONFIGURATION SETTINGS (which are also accessors)

=head2 add_comp_root

Configurable arrayref of additional Mason component roots.  These will
be searched before the default ones.  Must be absolute paths.

=cut

# munges the interp_args comp_root to include the add_comp_root
# configuration, plus the comp roots for SiteFeatures
sub COMPONENT {
    my ( $class, $c, $args ) = @_;

    $args = $class->merge_config_hashes( $class->config, $args );

    # coerce add_comp_root to arrayref
    if( $args->{add_comp_root} && ! ref $args->{add_comp_root} ) {
        $args->{add_comp_root} = [ $args->{add_comp_root} ];
    }

    # add comp roots for features and add_comp_root
    unshift @{ $args->{interp_args}->{comp_root} }, (
            # add_comp_root
            ( map [ additional => $_ ], @{ $args->{add_comp_root} || [] } ),
    );

    return $class->new($c, $args);
}

=head1 FUNCTIONS

=head2 $self->component_exists($component)

Check if a Mason component exists. Returns 1 if the component exists, otherwise 0.

=cut

sub component_exists {
    my ( $self, $component ) = @_;

    return $self->interp->comp_exists( $component ) ? 1 : 0;
}



__PACKAGE__->meta->make_immutable;
1;