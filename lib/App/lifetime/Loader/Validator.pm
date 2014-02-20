package App::lifetime::Loader::Validator;

use Moo;
use ThaiSchema;

use App::lifetime::Exception qw(throw_json_exception);

my $schema = type_array(type_hash( { name   => type_str,
                                     events => type_maybe(type_array(type_hash( { start => type_str,
                                                                                  end   => type_str,
                                                                                  type  => type_str } ))) } ));

sub validate {
    my $self = shift;
    my $data = shift;
    match_schema($data, $schema)
        or throw_json_exception("JSON doesn't match schema");
    1;
}



1;
