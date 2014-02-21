package App::lifetime::GUI;

use strict;
use warnings;

use App::lifetime::Loader;

use Gtk3 qw(-init);
use Data::Dumper;

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

    $self->{drawingarea} = $builder->get_object('drawingarea');

    $self;
}

sub _on_quit { Gtk3->main_quit }

sub _on_open {
    my $self = shift;
    my $filechooser = Gtk3::FileChooserDialog->new("Lifetime - Open file",
                                                   $self->{window},
                                                   "open",
                                                   'gtk-cancel' => 'cancel',
                                                   'gtk-open' => 'accept');

    while ($filechooser->run eq 'accept') {
        my $fn = $filechooser->get_filename;
        print "opening $fn\n";
        my $universe = eval { $self->_load_file($fn) };
        if ($universe) {
            print "new universe loaded\n";
            $self->{universe} = $universe;
            $self->_zoom_all;
            # $self->{drawingarea}->queue_draw;
            last;
        }
        warn "Unable to load file: $@";
    }
    $filechooser->destroy;
}

sub _load_file {
    my ($self, $fn) = @_;
    App::lifetime::Loader->new->load_from_file($fn);
}

sub _on_draw {
    my ($self, $drawingarea, $cr) = @_;

    #my $class = ref $cr;
    #    no strict;
    #print STDERR join("\n", keys(%{$class."::"}), "\n");

    print "drawing graph\n";

    if (0) {
        my $gdk_window = $drawingarea->get_bin_window;

        do {
            print STDERR Dumper($gdk_window), "\n";
            no strict 'refs';
            print STDERR Dumper \%{ref $gdk_window};
        };

        $cr = $gdk_window->cairo_create;
    }

    if (my $universe = $self->{universe}) {
        $self->_draw_universe($universe, $cr);
    }
    else {
        $cr->rectangle(10, 10, 40, 40);
        $cr->set_source_rgb(1.0, 0.5, 0.2);
        $cr->fill;
    }
}

sub _zoom_all {
    my $self = shift;
    my $dpx = $self->{drawingarea}
}

sub _draw_universe {
    my ($self, $universe, $cr) = @_;
    
}

sub run {
    my $self = shift;
    #$self->{drawingarea}->set_size_request(2000, 2000);
    $self->{window}->show_all();
    Gtk3->main();
}

1;
