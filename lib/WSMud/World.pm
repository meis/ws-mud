package WSMud::World;

sub new
{
  my $class = shift;
  my $self = {
    $online_players => {},
    @map => []
  };
  
  bless $self;
  
  $self->populate_map;
  return $self;
}

sub join
{
  my ($self, $player) = @_;
  
  $player_name = $player->{name};
  
  if ($self->is_online($player)) 
  {
    $self->notify_player($player, type => 'error', text => "This user is active, please choose another one.");
    $self->disconnect($player);
  } 
  else 
  { 
    $self->add_player($player);
    $self->notify_all($player, type => 'message', text => "$player_name enters the game.");
  }
}

sub left
{
  my ($self, $player) = @_;  
  
  $self->notify_player($player, type => 'message', text => "Goodbye");
  $self->notify_all(null, type => 'message', text => "$player->{name} left the game.");
  $self->rem_player($player);
  $self->disconnect($player)
}

sub disconnect
{
  my ($self, $player) = @_;  
  $player->disconnect;
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

sub players_in_room
{
  $self->{online_players};
}

sub notify_player 
{
  my ($self, $player, %notification) = @_;
  $player->notify(%notification);
}

# Notify all players in world, except the player who notifies.
sub notify_all
{
  my ($self, $player, %notification) = @_;
  
  for (values %$self->{online_players}) { 
    $self->notify_player($_, %notification) unless ($_ eq $player);
  }   
}

# Notify all players in room, except the player who notifies.
sub notify_room
{
  my ($self, $player, %notification) = @_;
  
  for (keys %$self->{online_players}) { 
    $self->{online_players}->{$_}->notify(%notification) unless ($_ == $player);
  }
}

sub dispatch_action
{
	WSMud::Action->dispatch(@_);
}

# This is a test subroutine which creates a sample map.
sub populate_map
{
	my @map = [];

	$map[1] = {
		brief 			=> 'Green room',
		description	=> 'This is a big green room. Everithing in the room is green.',
		exits				=> {'n' => 2, 'e' => 4}
	};

	$map[2] = {
		brief 			=> 'Red room',
		description	=> 'This is a big red room. Everithing in the room is red.',
		exits				=> {'s' => 1, 'e' => 3}
	};

	$map[3] = {
		brief 			=> 'Blue room',
		description	=> 'This is a big blue room. Everithing in the room is blue.',
		exits				=> {'w' => 2, 's' => 4}
	};

	$map[4] = {
		brief 			=> 'Yellow room',
		description	=> 'This is a big yellow room. Everithing in the room is yellow.',
		exits				=> {'w' => 1, 'n' => 3}
	};
	
	$self->{map} = @map;
}

1;
