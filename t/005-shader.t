#!perl

use v5.38;

use Time::HiRes qw[ sleep time ];
use Math::Trig;

use Philo;

my $height = 60;
my $width  = 80;

my $s = Philo::Shader->new(
    height   => $height,
    width    => $width,
    shader   => sub ($x, $y, $t) {

        my $d = sqrt(($x*$x) + ($y*$y));

        return (
            0,
            0,
            abs(
                sin($t * 0.5 - $d * 2.5 + $y) +
                sin($t * 0.9 - $d * 1.9 + $y)
            ),
        )
    }
);

my $frames = 0;
my $start  = time;

$SIG{INT} = sub {
    my $dur = time - $start;
    my $fps = $frames / $dur;
    $s->show_cursor;

    say "\n\nInteruptted!";
    say "Frames: $frames time: $dur fps: $fps";
    die "Goodbye";
};

$s->clear_screen;
$s->hide_cursor;

my $t = 0;
while (1) {
    $s->draw( time );
    $frames++;
}

$s->show_cursor;

