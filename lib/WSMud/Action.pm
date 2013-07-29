package WSMud::Action;
use Moose;
use Try::Tiny;

#TODO: Need some metaprograming or a way to register actions here...
sub dispatch {
    my ($self, $world, $player, $notification) = @_;

    my $type = $notification->type;
    my $call = [ split(" ", $notification->text) ];

    if ( $type eq 'cmd' ) {
        try {
            my $action_name = "action_" . @$call[0];
            $self->$action_name($world, $player, $call);
        }
        catch {
            $self->action_default($world, $player, $call);
        };
    }

}

sub action_help {	
    my ($self, $world, $player, $call) = @_;
	$world->notify_player( $player, WSMud::Notification->new({ type => 'help', text => "Available commands: help say move look quit." }) );
}

sub action_say {
	my ($self, $world, $player, $call) = @_;
	shift @$call;
	my $msg = join(" ", @$call);
	$world->notify_player( $player, WSMud::Notification->new({ type => 'message', text => "You say: $msg"}) );				
	$world->notify_room( $player, WSMud::Notification->new({ type => 'message', text => $player->name . " says: $msg"}) );
}

sub action_look {	
    my ($self, $world, $player, $call) = @_;
    $world->look_room($player);
}

sub action_move {
    my ($self, $world, $player, $call) = @_;
    $world->move($player, @$call[1]);
}

sub action_quit {
    my ($self, $world, $player, $call) = @_;
    $world->left($player);	
}

sub action_default {
    my ($self, $world, $player, $call) = @_;
    $world->notify_player( $player, WSMud::Notification->new({ type => 'error', text => "Command not found. Try 'help'." }) );
}

1;
