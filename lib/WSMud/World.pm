package WSMud::World;

sub new
{
  my $class = shift;
  my $self = {
    $online_players => {},
    $map => {},
  };

  bless $self;
  return $self;
}

sub join
{
  my ($self, $player) = @_;
  
  $player_name = $player->{name};
  if ($self->is_online($player)) {
    return -1;
  } else { 
    $self->add_player($player);
    $self->notify("god", type => 'message', text => "$player_name enters the game.");
  }
}

sub left
{
  my ($self, $player) = @_;  
  
  $self->notify("god", type => 'message', text => "$player->{name} left the game.");
  $self->rem_player($player);
}

sub notify
{
  my ($self, $player, %attrs) = @_;
  
  for (keys %$self->{online_players}) { 
    $self->{online_players}->{$_}->notify(%attrs) unless ($_ eq $player);
  } 
}

sub add_player
{
  my ($self, $player) = @_;
  $self->{online_players}->{$player->{name}} = $player;
}

sub rem_player
{
  my ($self, $player) = @_;
  delete $self->{online_players}->{$player->{name}};
}

sub is_online
{
  my ($self, $player) = @_;
  exists $self->{online_players}->{$player->{name}};
}

1;
