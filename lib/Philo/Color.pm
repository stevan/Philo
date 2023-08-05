
use v5.38;
use experimental qw[ class ];

class Philo::Color {
    field $r :param;
    field $g :param;
    field $b :param;

    method r { $r }
    method g { $g }
    method b { $b }

    method rgb { $r, $g, $b }

    method equals ($c) { $r == $c->r && $g == $c->g && $b == $c->b }

    method clone { Philo::Color->new( r => $r, g => $g, b => $b ) }
}

__END__
