package WSMud::World;

use feature 'switch';

sub new
{
  my $class = shift;
  my $self = {
    $online_players => {},
  };
  
  bless $self;
  return $self;
}

sub join
{
  my ($self, $player) = @_;
  
  $player_name = $player->{name};
  
  if ($self->is_online($player)) 
  {
    $self->notify_player($player, type => 'error', text => "This user is active, please choose another one.");
    $player->disconnect;
  } 
  else 
  { 
    $self->add_player($player);
    $self->notify_all(null, type => 'message', text => "$player_name enters the game.");
  }
}

sub left
{
  my ($self, $player) = @_;  
  $self->notify_player($player, type => 'message', text => "Goodbye");
  $self->notify_all($player, type => 'message', text => "$player->{name} left the game.");
  $self->rem_player($player);
  $player->disconnect;
}

sub notify_player 
{
  my ($self, $player, %attrs) = @_;
  $player->notify(%attrs);
}

# Notify all players in world, except the player who notifies.
sub notify_all
{
  my ($self, $player, %attrs) = @_;
  
  for (keys %$self->{online_players}) { 
    $self->{online_players}->{$_}->notify(%attrs) unless ($_ eq $player);
  } 
}

# Notify all players in room, except the player who notifies.
sub notify_room
{
  
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

sub dispatch_action
{
  my $self    			= shift;  
  my $player        = shift;
  my $notification	= WSMud::Notification->decode(shift);
  
  my $type 	= $notification->{type};
  
  my @call = split(" ", $notification->{text});
  
  for ($type)
  {
  	when('cmd')
  	{
  		for ($call[0])
  		{
  			when('help') 
  			{
  				$player->notify(type => 'message', text => "Available commands: help say move look quit.");		
  			}
  			when('say') 
  			{
  				shift @call;
  				my $msg = join(" ", @call);
  				$self->notify_player($player, type => 'message', text => "You say: $msg");	  				
  				$self->notify_all($player, type => 'message', text => "$player->{name} says: $msg");	
  			}
  			when('move') 
  			{
  				$self->notify_player($player, type => 'message', text => "In progress.");		
  			}
  			when('look') 
  			{
  				$self->notify_player($player, type => 'message', text => "Beautiful room. In progress.");		
  			}  			
  			when('quit') 
  			{
  				$self->left($player);	
  			}
  			default
  			{
  				$self->notify_player($player, type => 'error', text => "Command not found. Try 'help'.");
  			}
  		}
  				
  	}
  }
}


1;
