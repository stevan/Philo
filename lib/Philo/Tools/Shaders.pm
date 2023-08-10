package Philo::Tools::Shaders;
use v5.38;

use List::Util qw[ min max ];
use Math::Trig qw[ atan ];

use Exporter 'import';

our @EXPORT = qw[
    fract
    distance
    clamp
    smooth
    smoothstep
    min
    max
];

sub fract ($v) {
    return int($v) - $v;
}

sub distance ($x, $y) {
    return sqrt(($x*$x) + ($y*$y))
}

sub clamp ($min, $max, $val) {
    return max( $min, min( $max, $val ) );
}

sub smooth ($x) {
    return ($x ** 2) * (3 - (2 * $x))
}

sub smoothstep ( $t1, $t2, $x ) {
    my $v = max( 0, min( 1, (($x - $t1) / ($t2 - $t1)) ) );
    return ($v ** 2) * (3 - (2 * $v));
}

__END__
