#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use Data::Dumper;
use Math::Trig;

use Philo;

my $HEIGHT = 80;
my $WIDTH  = 120;

my $s = Philo::Shader->new(
    height => $HEIGHT,
    width  => $WIDTH,
    shader => sub ($p, $t) {

        my $freq = 0.015;

        my $v = int( ($HEIGHT * 0.5)  * (1.0 + (sin( 2 * pi * $freq * $p->x + $t))) );

        #warn "$v \n";

        return Philo::Color->new(
            r => 0.5,
            g => ($p->x ? (1/$p->x) : 0.5),
            b => ($p->y ? (1/$p->y) : 0.5),
        ) if $p->y == $v;

        return Philo::Color->new( r => 0, g => 0, b => 0 );
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
    #sleep(0.3);
}

$s->show_cursor;

