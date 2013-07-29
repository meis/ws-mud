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
    my $self    = shift;
    # For closure purposes.
    my $player  = $self;
    my $world   = $player->{world};

    $self->{connection}->on(message =>
        sub {$world->dispatch_action($player, $_[1])}
    );

    $self->{connection}->on(finish =>
        sub {$world->left($player)}
    );
}

sub notify { 
    my ($self, %attrs) = @_;
    my $notification = WSMud::Notification->new(%attrs);

    $self->connection->send($notification->encode);
}

sub disconnect {
    my $self = shift;

    $self->connection->finish;
}

1;
