package WSMud::Notification;

sub new 
{
  my ($class, %attrs) = @_;

  bless \%attrs, $class;
}

sub encode 
{
  my $self = shift;
  my $json = Mojo::JSON->new;
  
  my $notification = { 
  	type  => $self->{type}, 
  	text  => $self->{text},
  	value => $self->{value},
  };  
  
  $notification->{color} = $self->{color} if exists $self->{color};
  return $json->encode($notification);
}

sub decode
{
  my $self = shift;  
  my $notification = shift;
  
  my $json = Mojo::JSON->new;
  return $json->decode($notification);  
}

1;
