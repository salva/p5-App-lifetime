package App::lifetime::Universe;

use Moo;

has things => (is => 'rwp', default => sub { [] });

sub add_thing {
    my ($self, $thing) = @_;
    push @{$self->things}, $thing;
}

1;
