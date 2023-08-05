
use v5.38;
use experimental qw[ class ];

class Philo::Point {
    field $x :param;
    field $y :param;

    method x { $x }
    method y { $y }

    method xy { $x, $y }
    method yx { $y, $x }

    method distance { sqrt(($x*$x) + ($y*$y)) }

    method equals ($p) { $x == $p->x && $y == $p->y }

    method clone ($p) { Philo::Point->new( x => $x, y => $y ) }
}

__END__
