package App::lifetime::Thing;

use Moo;

has seq  => (is => 'ro');
has name => (is => 'ro');

has events => (is => 'ro', default => sub {[]});

use App::lifetime::Thing::Event;

sub add_new_event {
    my $self = shift;
    my $event = App::lifetime::Thing::Event->new(@_);
    push @{$self->events}, $event;
}

1;
