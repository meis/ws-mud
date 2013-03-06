package WSMud::Player;

sub new
{
  my $class = shift;
  my $self = {
    name        => shift,
    world       => shift,
    connection  => shift,
  };
  
  bless $self, $class;   
   
  $self->{world}->join($self);
    
  $self->init_connection;    
  
  return $self;
}

sub init_connection
{
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

sub notify
{ 
  my ($self, %attrs) = @_;
  my $notification = WSMud::Notification->new(%attrs);
  
  $self->{connection}->send($notification->encode);
}

sub disconnect
{
  my $self = shift;
  
  $self->{connection}->finish;
}

1;
