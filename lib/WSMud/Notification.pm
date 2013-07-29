package WSMud::Notification;
use Moose;

has 'type'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'text'  => ( is => 'ro', isa => 'Str' );
has 'value' => ( is => 'ro', isa => 'Str' );
has 'color' => ( is => 'ro', default => sub { undef } );

sub encode {
    my $self = shift;
    my $json = Mojo::JSON->new;

    my $notification = {
        type  => $self->type,
        text  => $self->text,
        value => $self->value,
    };

    $notification->{color} = $self->color if $self->color;
    return $json->encode($notification);
}

sub decode {
    my ($class, $notification) = @_;

    my $json = Mojo::JSON->new;
    return $class->new( $json->decode($notification) );
}

1;
