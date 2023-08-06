#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use List::Util  qw[ min max ];
use Math::Trig;
use Data::Dumper;

use Philo;

my $HEIGHT = 80;
my $WIDTH  = 120;

class Wave {
    use Math::Trig;

    field $frequency :param;
    field $amplitude :param;
    field $type      :param;

    field $f;

    ADJUST {
        no strict 'refs';
        $f = \&{"CORE::${type}"};
    }

    method calculate_at ($x, $t) {
        ($amplitude * $f->( 2 * pi * $frequency * $x + $t ));
    }
}

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {

        state $H = $HEIGHT * 0.5;

        state @ws = (
            Wave->new( frequency => 1, amplitude => 0.50, type => 'sin' ),
            Wave->new( frequency => 2, amplitude => 0.25, type => 'sin' ),
            Wave->new( frequency => 3, amplitude => 0.25, type => 'cos' ),
            Wave->new( frequency => 4, amplitude => 0.09, type => 'sin' ),
        );

        my $v = 0;
        foreach my $w ( @ws ) {
            $v -= $w->calculate_at(
                $p->x,
                $t
            );
        }

        #$v /= scalar @ws;

        return Philo::Color->new(
            r => 1,
            g => 1,
            b => 0,
        ) if ceil($p->y * $H) == ceil($v * $H);

        return Philo::Color->new( r => 0.5, g => 0, b => 0 );
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
    my $t = time;
    $s->draw( $t );
    my $d = (time() - $t);
    say "avg fps  : " . $frames / ($t - $start);
    say "cur fps  : " . (1 / $d);
    say "duration : " . $d;
    say "frames   : " . $frames++;
    say "now      : " . $t;
    #sleep(0.03);
    #last; # if $frames == $WIDTH;
}

$s->show_cursor;

