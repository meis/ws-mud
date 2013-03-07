package WSMud::World;

sub new
{
  my $class = shift;
  my $self = {
    $online_players => {},
    @zone_map => [],
    %positions = {},
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
    $self->notify_player($player, type => 'error', text => "Welcome to the game.");
    $self->notify_player($player, type => 'error', text => "If you don't know what to do, type 'help'");
    $self->notify_all($player, type => 'message', text => "$player_name enters the game.");
    $self->enter_room($player, $self->initial_room($player));
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

# As we don't have persistent layer we need to start ever at the same point.
sub initial_room
{
  my ($self, $player) = @_;  
 
  $self->{zone_map}[1];
}

sub players_in_room
{
  my ($self, $room) = @_;
  $self->{online_players};
}

sub enter_room
{
  my ($self, $player, $room) = @_;

  
  $self->update_position($player, $room);
  $self->notify_player($player, type => 'room:glance', text => $room->glance);
  $self->notify_players_in_room($player, $room);
}

sub move
{
}

sub update_position 
{
  my ($self, $player, $room) = @_;
  
  $self->{positions}{$player->{name}} = $room->{id};
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
  
  for (values %$self->{online_players}) 
  { 
    $self->notify_player($_, %notification) unless ($_ eq $player);
  }   
}

# Notify all players in room, except the player who notifies.
sub notify_room
{
  my ($self, $player, %notification) = @_;
  
  for (keys %$self->{online_players}) 
  { 
    $self->{online_players}->{$_}->notify(%notification) unless ($_ == $player);
  }
}

sub notify_players_in_room
{
  my ($self, $player, $room) = @_;
  for (values %{$self->players_in_room($room)})
  {
    $self->notify_player($player, type => 'room:glance', text => "$_->{name} is here.") unless ($_ eq $player);
  }
}

sub dispatch_action
{
	WSMud::Action->dispatch(@_);
}

# This is a test subroutine which creates a sample map.
#TODO: Use a graph-like objecto to store map.
sub populate_map
{
  my $self = shift;

	$self->{zone_map}[1] = WSMud::Room->new(
	  id          => 1,
		brief 			=> 'Green room',
		description	=> 'This is a big green room. Everything in the room is green.',
		exits				=> {'n' => 2, 'e' => 4}
	);

	$self->{zone_map}[2] = WSMud::Room->new(
	  id          => 2,
		brief 			=> 'Red room',
		description	=> 'This is a big red room. Everything in the room is red.',
		exits				=> {'s' => 1, 'e' => 3}
	);

	$self->{zone_map}[3] = WSMud::Room->new(
	  id          => 3,
		brief 			=> 'Blue room',
		description	=> 'This is a big blue room. Everything in the room is blue.',
		exits				=> {'w' => 2, 's' => 4}
	);

	$self->{zone_map}[4] = WSMud::Room->new(
	  id          => 4,
		brief 			=> 'Yellow room',
		description	=> 'This is a big yellow room. Everything in the room is yellow.',
		exits				=> {'w' => 1, 'n' => 3}
	);	
}

1;
