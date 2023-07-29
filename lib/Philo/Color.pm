
use v5.38;
use experimental qw/ class try /;

class Philo::Color {
    use Carp qw/ confess /;

    field $r :param;
    field $g :param;
    field $b :param;

    ADJUST {
        $r <= 1 >= 0 || confess "The `r` value must be between 0 and 1, not $r";
        $g <= 1 >= 0 || confess "The `g` value must be between 0 and 1, not $g";
        $b <= 1 >= 0 || confess "The `b` value must be between 0 and 1, not $b";
    }

    method r { $r }
    method g { $g }
    method b { $b }

    method rgb { $r, $g, $b }

    method add ($c) { Philo::Color->new( r => $r + $c->r, g => $g + $c->g, b => $b + $c->b ) }
    method sub ($c) { Philo::Color->new( r => $r - $c->r, g => $g - $c->g, b => $b - $c->b ) }

    method equals ($c) { $r == $c->r && $g == $c->g && $b == $c->b }

    method clone { Philo::Color->new( r => $r, g => $g, b => $b ) }
}

__END__
