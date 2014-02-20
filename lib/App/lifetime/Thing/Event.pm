package App::lifetime::Thing::Event;

use Moo;

has start => (is => 'ro');
has end   => (is => 'ro');
has type  => (is => 'ro');

1;
