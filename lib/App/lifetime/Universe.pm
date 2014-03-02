package App::lifetime::Universe;

use Moo;

has things => (is => 'rwp', default => sub { [] });
has _changed => (is => 'rw', default => sub { 1 });
has _min => (is => 'rw');
has _max => (is => 'rw');

sub add_thing {
    my ($self, $thing) = @_;
    push @{$self->things}, $thing;
}

sub _rethink {
    my $self = shift;
    return unless $self->_changed;
    my ($max, $min);
    my $things = $self->things;
    if (@$things) {
        for my $thing (@$things) {
            $thing->_rethink;
            my $tmax = $thing->max;
            my $tmin = $thing->min;
            if (defined $max) {
                $max = $tmax if $tmax > $max;
                $min = $tmin if $tmin < $min;
            }
            else {
                $max = $tmax;
                $min = $tmin;
            }
        }
        $self->_min($min);
        $slef->_max($max);
    }
    $self->_changed(undef);
}

sub width {
    my $self = shift;
    @{$self->things} or return;
    $self->_rething;
    $self->_max - $self->_min;
}

1;
