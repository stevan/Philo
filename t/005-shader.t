#!perl

use v5.38;

use Time::HiRes qw[ sleep time ];
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Philo;

my $height = 100;
my $width  = 100;

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $height,
    width        => $width,
    shader       => sub ($x, $y, $t) {

        my $d  = sqrt(($x*$x) + ($y*$y));
           $d *= 100;

        return map abs, $x * $y,0,0 if ($d % 5) == 0;

        return 0,0,0;
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
    #sleep(0.1);
}

$s->show_cursor;

