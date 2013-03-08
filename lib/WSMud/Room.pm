package WSMud::Room;

sub new 
{
  my ($class, %attrs) = @_;

  bless \%attrs, $class;
}

sub glance
{
  my $self = shift;
  
  $self->{brief} . ' [' . join(", ", keys %{$self->{exits}}) . ']';  
}

sub look
{
  my $self = shift;
  
  $self->{description};  
}

1;
