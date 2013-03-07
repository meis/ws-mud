package WSMud::Action;

use feature 'switch';

#TODO: Need some metaprograming here...
sub dispatch
{
  my $self    			= shift;  
  my $world					= shift;
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
  				$self->action_help($world, $player, @call);	
  			}
  			when('say') 
  			{
  				$self->action_say($world, $player, @call);	
  			}
  			when('move') 
  			{
  				$self->action_move($world, $player, @call);
  			}
  			when('look') 
  			{
  				$self->action_look($world, $player, @call);
  			}  			
  			when('quit') 
  			{
  				$self->action_quit($world, $player, @call);
  			}
  			default
  			{
  				$self->action_default($world, $player, @call);
  			}
  		}
  				
  	}
  }
}

sub action_help 
{	
  my ($self, $world, $player, @call) = @_;
	$world->notify_player($player, type => 'message', text => "Available commands: help say move look quit.");
}

sub action_say
{
	my ($self, $world, $player, @call) = @_;
	shift @call;
	my $msg = join(" ", @call);
	$world->notify_player($player, type => 'message', text => "You say: $msg");	  				
	$world->notify_all($player, type => 'message', text => "$player->{name} says: $msg");
}

sub action_look 
{	
  my ($self, $world, $player, @call) = @_;
	$world->notify_player($player, type => 'message', text => "Beautiful room. In progress.");
}

sub action_move
{
  my ($self, $world, $player, @call) = @_;
	$world->notify_player($player, type => 'message', text => "In progress.");
}

sub action_quit
{
  my ($self, $world, $player, @call) = @_;
	$world->left($player);	
}

sub action_default
{
  my ($self, $world, $player, @call) = @_;
	$world->notify_player($player, type => 'error', text => "Command not found. Try 'help'.");
}

1;
