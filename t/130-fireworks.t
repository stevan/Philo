#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use Data::Dumper;

use Philo;
use Philo::Tools::Shaders;

my $HEIGHT = 50;
my $WIDTH  = 50;


sub Hash12 ($t) {
    my $x = fract(sin($t * 674.3) * 453.2 ) * 6.2832;
    my $y = fract(sin(($t + $x) * 714.3) * 263.2 );

    return (sin($x) * $y, cos($x) * $y);
}


my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {
        state $NUM_STARS = 25;
        state $HASHES    = [ map { [ Hash12( $_ + 2 ) ] } 0 .. $NUM_STARS ];

        my $v;
        for( my $i = 0.0; $i < $NUM_STARS; $i++ ) {
            my ($x, $y) = $p->xy;

            my ($x_dir, $y_dir) = $HASHES->[ $i ]->@*;
            my $offset = fract( $t * 0.25 );

            #warn join ', ' => ($x_dir, $y_dir, $offset), "\n";

            $x -= ($x_dir * $offset);
            $y -= ($y_dir * $offset);

            my $d = distance( $x, $y );

            my $b = 0.005;
            $v += $b/$d;
        }

        $v = clamp( 0, 1, $v );

        return Philo::Color->new(
            r => $v,
            g => 0, #$v,
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



