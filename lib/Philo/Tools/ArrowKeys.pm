
use v5.38;
use experimental qw[ class ];
use roles ();

class Philo::Tools::ArrowKeys {
    use Carp qw[ confess ];

    use Term::ReadKey;

    my $UP_ARROW    = "\e[A";
    my $DOWN_ARROW  = "\e[B";
    my $RIGHT_ARROW = "\e[C";
    my $LEFT_ARROW  = "\e[D";

    field $fh :param;

    field @recievers;

    method add_reciever ($r) {
        $r->roles::DOES('Philo::Roles::Oriented')
            || confess "Receivers must do the Oriented role ($r)";
        push @recievers => $r;
        $self;
    }

    method turn_echo_off { ReadMode cbreak  => $fh }
    method turn_echo_on  { ReadMode restore => $fh }

    method capture_keypress {
        my $message = ReadKey -1, $fh;
        return unless $message;

        if ( $message eq "\e" ) {
            $message .= ReadKey -1, $fh;
            $message .= ReadKey -1, $fh;
        }

        map { $_->go_up    } @recievers if $message eq $UP_ARROW;
        map { $_->go_down  } @recievers if $message eq $DOWN_ARROW;
        map { $_->go_right } @recievers if $message eq $RIGHT_ARROW;
        map { $_->go_left  } @recievers if $message eq $LEFT_ARROW;
    }
}

__END__
