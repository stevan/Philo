#!perl

use v5.38;

use Time::HiRes qw[ sleep time ];
use Math::Trig;

use Philo;

my $height = 60;
my $width  = 60;

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $height,
    width        => $width,
    shader       => sub ($p, $t) {

        my $d = $p->distance;
        my ($x, $y) = $p->xy;

        return Philo::Color->new(
            r => abs(sin($t * 1.0 - $d * 1.0 + $x * $y)),
            g => abs(sin($t * 1.0 - $d * 1.0 + $x)),
            b => abs(cos($t * 5.0 - $d * 0.3 + $y)),
        )
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

run_shader( $s );

