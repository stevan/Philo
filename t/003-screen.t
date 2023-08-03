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
    shader       => sub ($x, $y, $t) {

        my $d = sqrt(($x*$x) + ($y*$y));

        return (
            abs(sin($t * 1.0 - $d * 1.0 + $x * $y)),
            abs(sin($t * 1.0 - $d * 1.0 + $x)),
            abs(cos($t * 5.0 - $d * 0.3 + $y)),
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

