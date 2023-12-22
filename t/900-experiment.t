#!perl

use v5.38;

use Time::HiRes qw[ sleep time ];
use Math::Trig;

use Philo;
use Philo::Tools::Shaders;

my $height = 80;
my $width  = 80;


my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $height,
    width        => $width,
    shader       => sub ($p, $t) {

        my ($x, $y) = $p->xy;

        my $d = ($x * $y) + $p->distance;

        return Philo::Color->new(
            r => smoothstep(0.30, 0.99, sin(($d * cos($x) + cos($t * 0.3)) * 4.3)),#smoothstep(0.09, 0.32, sin(($d * sin($p->distance * $y) + ($t * 0.3)) * 4.5)),
            g => smoothstep(0.10, 0.59, sin(($d * sin($y) + cos($t * 0.5)) * 9.3)),
            b => smoothstep(0.30, 0.99, sin(($d * cos($x) + sin($t * 0.2)) * 6.3)),#smoothstep(0.15, 0.49, cos(($d + sin($y) * ($t * 0.2)) * 9.9)),
        );
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
        sleep( $delay ) if $delay;
        my $d = (time() - $t);
        say "frame    : " . $frames++;
        say "fps      : " . $frames / ($t - $start);
        say "duration : " . $d;
        say "elapsed  : " . ($t - $start);
    }

    $s->show_cursor;
}

run_shader( $s, 0.01 );

