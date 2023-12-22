#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use Data::Dumper;

use Philo;
use Philo::Tools::Shaders;

my $HEIGHT = 80;
my $WIDTH  = 80;

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

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {

        state $w1 = Wave->new( function  => 'cos', amplitude => rand() * rand(), frequency => rand() * 0.5 );
        state $w2 = Wave->new( function  => 'sin', amplitude => rand() * rand(), frequency => rand() * 2 );
        state $w3 = Wave->new( function  => 'sin', amplitude => rand() * rand(), frequency => rand() * 3 );
        state $w4 = Wave->new( function  => 'cos', amplitude => rand() * rand(), frequency => rand() * 0.7 );

        my ($x, $y) = $p->xy;

        my $v = $w1->calculate_at( $x + $t );
          $v -= $w2->calculate_at( $x + $t * 0.3 );
          $v += $w3->calculate_at( $x + $t * 0.6 );
          $v += $w4->calculate_at( $x + $t * 1.3 );

        $v /= 4;

        my $d = abs(($x * $y) + $p->distance);

        $v = smoothstep(
            smoothstep( 0.5, 0, ($v - ($d)) ),
            smoothstep( 0.5, 1, ($v - ($d)) ),
            abs($v - $y)
        );

        return Philo::Color->new(
            r => smoothstep( 0.2, 0.5, smoothstep( 0.6, 0.9, ($v - ($d)) ) ),
            g => smoothstep( 0.1, 0.7, smoothstep( 0.3, 0.7, ($v - ($d)) ) ),
            b => smoothstep( 0.1, 0.4, smoothstep( 0.2, 0.8, ($v - ($d)) ) ),
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
    #$s->enable_alt_buffer;

    my $t = 0;
    while (1) {
        my $t = time;
        $s->draw( $t );
        sleep( $delay ) if $delay;
        my $d = (time() - $t);
        say "frame    : " . $frames++;
        say "fps      : " . $frames / ($t - $start);
        say "duration : " . $d;
        say "elapsed  : " . ($t - $start);
    }

    $s->show_cursor;
    #$s->disable_alt_buffer;
}

run_shader( $s );


