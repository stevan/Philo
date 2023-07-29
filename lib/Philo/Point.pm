
use v5.38;
use experimental qw/ class try /;

class Philo::Point {
    field $x :param;
    field $y :param;

    method x { $x }
    method y { $y }

    method xy { $x, $y }
    method yx { $y, $x }

    method add ($p) { Philo::Point->new( x => $x + $p->x, y => $y + $p->y ) }
    method sub ($p) { Philo::Point->new( x => $x - $p->x, y => $y - $p->y ) }

    method distance { sqrt(($x*$x) + ($y*$y)) }

    method equals ($p) { $x == $p->x && $y == $p->y }
}

__END__
