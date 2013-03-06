package WSMud::Player;

use feature 'switch';

sub new
{
  my $class = shift;
  my $self = {
    name        => shift,
    world       => shift,
    connection  => shift,
  };
  
  bless $self, $class;   
   
  $self->{world}->join($self) == 0 ?
    $self->init_connection:  
    $self->emergency_exit("This user is active, please choose another one."); 
  
  return $self;
}

sub init_connection
{
  my $self        = shift;
  # For closure purposes.
  my $player      = $self;
  
  $self->{connection}->on(message =>
    sub {$player->do_action($_[1])}
  );

  $self->{connection}->on(finish =>
    sub {$player->exit}
  );
}

sub notify
{ 
  my ($self, %attrs) = @_;
  my $notification = WSMud::Notification->new(%attrs);
  
  $self->{connection}->send($notification->encode);
}

sub notify_world
{ 
  my ($self, %attrs) = @_;
  
  $self->{world}->notify($self->{name}, %attrs);
}

sub do_action
{
  my $self    			= shift;  
  my $notification	= WSMud::Notification->decode(shift);
  
  my $type 	= $notification->{type};
  my $me 		= $self->{name};
  
  my @call = split(" ", $notification->{text});
  
  for ($type)
  {
  	when('cmd')
  	{
  		for ($call[0])
  		{
  			when('help') 
  			{
  				$self->notify(type => 'message', text => "Available commands: help say.");		
  			}
  			when('say') 
  			{
  				shift @call;
  				my $msg = join(" ", @call);
  				$self->notify(tpye => 'message', text => "You say: $msg");	  				
  				$self->notify_world(tpye => 'message', text => "$me says: $msg");	
  			}
  			when('move') 
  			{
  				$self->notify(type => 'message', text => "In progress.");		
  			}
  			default
  			{
  				$self->notify(type => 'error', text => "Command not found. Try 'help'.");
  			}
  		}
  				
  	}
  }
}

sub emergency_exit
{
  my $self = shift;
  my $text = shift;
  
  $self->notify(tpye => 'message', text => $text);
  $self->{connection}->on(finish => sub {return 0});
  $self->{connection}->finish;
}

sub exit
{
  my $self = shift;
  
  $self->notify(tpye => 'message', text => "Goodbye");
  $self->{world}->left($self);   
  $self->{connection}->finish;
}

1;
