package App::lifetime::Loader;

use Moo;

use App::lifetime::Loader::Validator;
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
    throw_io_exception(message => "Unable to read data from '$fn'", err => $!);
}

sub load_from_string {
    my ($self, $json) = @_;
    my @things;
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
                    $thing->add_new_event(%$e);
                }
            }
            push @things, $thing;
        };
    };
    $@ and throw_json_exception(message => "Unable to decode JSON data: $@", err => $@);
    @things;
}

1;
