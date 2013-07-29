package WSMud::Player;
use Moose;

has 'name'       => ( is => 'ro', required => 1, isa => 'Str' );
has 'world'      => ( is => 'ro', required => 1 );
has 'connection' => ( is => 'ro', required => 1 );

sub BUILD {
    my $self = shift;

    $self->world->enter($self);

    $self->init_connection;

    return $self;
}

sub init_connection {
    my $self = shift;

    $self->{connection}->on(message =>
        sub { $self->world->dispatch_action( $self, WSMud::Notification->decode($_[1]) ) }
    );

    $self->{connection}->on(finish =>
        sub { $self->world->left($self) }
    );
}

sub notify {
    my ($self, $notification) = @_;

    $self->connection->send($notification->encode);
}

sub disconnect {
    my $self = shift;

    $self->connection->finish;
}

1;
