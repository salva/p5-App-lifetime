package App::lifetime::Loader;

use strict;
use warnigs;

use Moo;

use App::lifetime::Thing;
use App::lifetime::Exception qw(throw_io_exception throw_json_exception);
use JSON;


sub new {
   my $class = shift;
   my $self = {};
   bless $self, $class;
}

sub load_from_file {
    my ($self, $fn) = @_;
    if (open my $fh, '<:encoding(utf8)', $fn) {
        my $json = do { undef $/; <$fh> };
        if (close $fh) {
            return $self->load_from_string($json);
        }
    }
    throw_io_exception("Unable to read data from '$fn'", err => $!);
}

sub load_from_string {
    my ($self, $json) = @_;
    my @things;
    eval {
        my $in = JSON::from_json($json, {utf8 => 1});
        my $seq = 0;
        for my $entry (@$in) {
            my %ctor_args = map { $_ => ${$in}{$_} } qw(name);
            my $thing = App::lifetime::Thing->new(seq => $seq++,
                                                  %ctor_args);
            if (my $events = $entry->{events}) {
                for my $e (@$events) {
                    my %event_args = map { $_ => ${$e}{$_} } qw(start end type);
                    $thing->add_event(%event_args);
                }
            }
            push @things, $thing;
        };
    };
    $@ and throw_json_exception("Unable to decode JSON data", err => $@);
}
