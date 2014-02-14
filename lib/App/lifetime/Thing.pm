package App::lifetime::Thing;

use Moo;

has seq  => (is => 'ro');
has name => (is => 'ro');

has events => (is => 'ro', default => sub {[]});

sub add_event {
    my ($self, %args) = @_;
    my %event = map { $_ => delete $args{$_} } qw(start end type);
    %args and die "Internal error: unexpected arguments: " . join(", ", keys %args);
    push @{$self->events}, \%event;
}

1;
