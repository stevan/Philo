#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use Data::Dumper;

use Philo;

my $HEIGHT = 60;
my $WIDTH  = 60;

my $s = Philo::Shader->new(
    height => $HEIGHT,
    width  => $WIDTH,
    shader => sub ($p, $t) {
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
    sleep(0.01);
}

$s->show_cursor;

