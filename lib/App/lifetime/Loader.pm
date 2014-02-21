package App::lifetime::Loader;

use Moo;

use App::lifetime::Loader::Validator;
use App::lifetime::Universe;
use App::lifetime::Thing;
use App::lifetime::Exception qw(throw_io_exception throw_json_exception);
use JSON;

use Regexp::Common;

my $num_re = $RE{num}{real}{-keep}{-sign => ''};

# my %time_units = (Year    => 365 * 24 * 60 * 60,
#                   Month   =>  30 * 24 * 60 * 60,
#                   Week    =>   7 * 24 * 60 * 60,
#                   Day     =>       24 * 60 * 60,
#                   hour    =>            60 * 60,
#                   min_ute =>                 60,
#                   sec_ond =>                  1);

sub _parse_time {
    my $time = shift // return;
    my $out;

    # 14.023s
    if (my ($s, $f) = $time =~ /^\s*$num_re\s*s?\s*$/io) {
        $out = eval $1;
    }
    else {
        $out = eval {
            # 2014-02-21 11:17:31.345656
            if (my ($Y, $M, $D, $h, $m, $s, $fr) = $time =~
                /^\s*(\d{4})-(\d{2})-(\d{2})[\s:\-](\d{2}):(\d{2}):(\d{2})(?:\.(\d*))?\s*$/) {
                require DateTime;
                $fr ||= 0;
                my $dt = DateTime->new(year => $Y,
                                       month => $M,
                                       day => $D,
                                       hour => $h,
                                       minute => $m,
                                       second => $s,
                                       nanosecond => "0.$fr" * 1e9,
                                       time_zone => 'UTC');
                return $dt->epoch;
            }
            else {
                die "unknown format";
            }
        };
    }
    $@ and throw_json_exception(message => "Unable to parse time field '$time': $@",
                                err => $@);
    $out;
}


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
    throw_io_exception(message => "Unable to read data from '$fn'", err => $!);
}

sub load_from_string {
    my ($self, $json) = @_;

    my $universe = App::lifetime::Universe->new;
    eval {
        my $in = JSON::from_json($json, {utf8 => 1});
        App::lifetime::Loader::Validator->validate($in);
        my $seq = 0;
        for my $entry (@$in) {
            #use Data::Dumper;
            #print Dumper $entry
            my $thing = App::lifetime::Thing->new(seq => $seq++,
                                                  name => $entry->{name});
            if (my $events = $entry->{events}) {
                for my $e (@$events) {
                    my %args = %$e;
                    $args{end} //= $args{start};
                    $_ = _parse_time($_) for @args{qw(start end)};
                    $thing->add_new_event(%args);
                }
            }
            $universe->add_thing($thing);
        };
    };
    $@ and throw_json_exception(message => "Unable to decode JSON data: $@", err => $@);
    $universe;
}

1;
