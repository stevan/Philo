#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use List::Util  qw[ min max ];
use Math::Trig;
use Data::Dumper;

use Philo;

my $HEIGHT = 100;
my $WIDTH  = 100;

class Wave {
    use Math::Trig;

    field $frequency :param;
    field $amplitude :param;
    field $function  :param;

    field $f;

    ADJUST {
        no strict 'refs';
        $f = \&{"CORE::${function}"};
    }

    method calculate_at ($p, $t=0) {
        ($amplitude * $f->( 2 * pi * $frequency * $p + $t));
    }
}

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

        state $w1 = Wave->new( function  => 'sin', amplitude => 0.2, frequency => 2 );
        state $w2 = Wave->new( function  => 'cos', amplitude => 0.3, frequency => 3 );

        my ($x, $y) = $p->xy;

        my $v = $w1->calculate_at( $x + $t );
          $v -= $w2->calculate_at( $x + $t * 0.5 );

        $v = smoothstep( 0, 0.1, abs($v - $y) );

        return Philo::Color->new(
            r => $v,
            g => $v,
            b => $v,
        );
    }
);

sub run_shader ($s, $delay=undef) {

    my $frames = 0;
    my $start  = time;

    $SIG{INT} = sub {
        $s->show_cursor;
        #$s->disable_alt_buffer;
        die "Interuptted!";
    };

    $s->clear_screen;
    $s->hide_cursor;
    $s->enable_alt_buffer;

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
    #$s->disable_alt_buffer;
}

run_shader( $s, 0.01 );


