package WSMud::Room;
use Moose;

has 'id'          => ( is => 'ro', isa => 'Int'    , required => 1 );
has 'brief'       => ( is => 'ro', isa => 'Str'    , required => 1 );
has 'description' => ( is => 'ro', isa => 'Str'    , required => 1 );
has 'color'       => ( is => 'ro', isa => 'Str'    , required => 1 );
has 'exits'       => ( is => 'ro', isa => 'HashRef', required => 1 );

sub glance {
    my $self = shift;

    $self->{brief} . ' [' . join(", ", keys %{$self->{exits}}) . ']';
}

sub look {
    my $self = shift;

    $self->{description};
}

1;
