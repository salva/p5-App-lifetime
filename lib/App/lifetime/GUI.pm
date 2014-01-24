package App::lifetime::GUI;

use strict;
use warnings;

use Gtk3 qw(-init);

use Method::WeakCallback qw(weak_method_callback);

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;

    my $uifn = $INC{"App/lifetime/GUI.pm"};
    $uifn =~ s/\.pm$/.ui/;
    my $builder = $self->{builder} = Gtk3::Builder->new();
    $builder->add_from_file($uifn);
    $builder->connect_signals(undef, $self);

    my $window = $self->{window} = $builder->get_object('window');
    $window->set_screen( $window->get_screen() );

    $self->{layout} = $builder->get_object('layout');

    $self;
}

sub _on_quit { Gtk3->main_quit }

use Data::Dumper;
sub _on_draw {
    my ($self, $layout, $cr) = @_;

    #my $class = ref $cr;
    #    no strict;
    #print STDERR join("\n", keys(%{$class."::"}), "\n");

    my @rect = $cr->clip_extents;
    print STDERR "rectangles:\n", Dumper(\@rect);

    $cr->rectangle(10, 10, 40, 40);
    $cr->set_source_rgb(1.0, 0.5, 0.2);
    $cr->fill;

}


sub run {
    my $self = shift;
    $self->{layout}->set_size(1000, 1000);
    $self->{window}->show_all();
    Gtk3->main();
}

1;
