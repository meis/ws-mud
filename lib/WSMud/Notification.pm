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
  
  $notification = { type => $self->{type}, text => $self->{text} };  
  return $json->encode($notification);
}

sub decode
{
  
}

1;
