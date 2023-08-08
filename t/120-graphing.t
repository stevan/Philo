#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use List::Util  qw[ min max ];
use Math::Trig;
use Data::Dumper;

use Philo;

my $HEIGHT = 80;
my $WIDTH  = 80;

# detect if we intersect with the function
sub intersect ($x_pos, $y_pos) {
    state $h = $HEIGHT * 0.25; # because we doubled the size of the screen below ...
    return ceil(-$x_pos * $h) == ceil($y_pos * $h);
}

# clamp values between min/max
sub clamp ($min, $max, $val) {
    return max( $min, min( $max, $val ) );
}

# this is a smoothing function
sub smooth ($x) {
    return ($x ** 2) * (3 - (2 * $x))
}

# smooth a clamped step with two independent thresholds
sub smoothstep ( $t1, $t2, $x ) {
    return smooth( clamp( 0, 1, (($x - $t1) / ($t2 - $t1)) ) );
}

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {
        state $red   = Philo::Color->new( r => 1, g => 0, b => 0 );
        state $green = Philo::Color->new( r => 0, g => 1, b => 0 );
        state $blue  = Philo::Color->new( r => 0, g => 0, b => 1 );
        state $white = Philo::Color->new( r => 1, g => 1, b => 1 );
        state $black = Philo::Color->new( r => 0, g => 0, b => 0 );

        my ($x, $y) = $p->xy;

        # double the size of the screen ...
        $x *= 2;
        $y *= 2;

        # simple clamped value
        return $red   if intersect( smooth( clamp( 0, 1, $x ) ), $y );

        # return a smoothsteped value
        my $d = smoothstep( 0, 0.5, $x );
        return $green if intersect( $d, $y );

        # smooth out a sine-wave with that value ...
        return $blue  if intersect( sin($x * 10) * $d, $y );

        #
        return Philo::Color->new(
            r => smoothstep( 0, 0.01, ($x) ),
            g => smoothstep( 0, 0.01, ($x) ),
            b => smoothstep( 0, 0.01, ($x) ),
        );

        return $black;
    }
);

sub run_shader ($s, $delay=undef) {

    my $frames = 0;
    my $start  = time;

    $SIG{INT} = sub {
        $s->show_cursor;
        die "Interuptted!";
    };

    $s->clear_screen;
    $s->hide_cursor;

    my $t = 0;
    while (1) {
        my $t = time;
        $s->draw( $t );
        my $d = (time() - $t);
        say "avg fps  : " . $frames / ($t - $start);
        say "cur fps  : " . (1 / $d);
        say "duration : " . $d;
        say "frames   : " . $frames++;
        say "now      : " . $t;
        sleep( $delay ) if $delay;
    }

    $s->show_cursor;
}

run_shader( $s );


