#!perl

use v5.38;
use experimental 'builtin';
use builtin qw[ floor ];

use Time::HiRes qw[ sleep time ];
use List::Util  qw[ max min ];

use Philo;

my $height = 60;
my $width  = 60;

sub pallete ($t) {
    state @a = (0.5, 0.5, 0.5);
    state @b = (0.5, 0.5, 0.5);
    state @c = (1.0, 1.0, 1.0);
    state @d = (0.263, 0.416, 0.557);

    my @r;
    foreach my $i ( 0, 1, 2 ) {
        my $a = $a[$i];
        my $b = $b[$i];
        my $c = $c[$i];
        my $d = $d[$i];

        $r[$i] = ($a + $b * cos( 6.28318 * ($c * $t + $d )));
    }

    return @r;
}

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $height,
    width        => $width,
    shader       => sub ($x, $y, $t) {

        my @final_color = (0, 0, 0);

        my $d0 = sqrt(($x*$x) + ($y*$y));

        for( my $i = 0.0; $i < 1.0; $i++ ) {

            # START REPETITION
            $x = $x * 1.5;
            $y = $y * 1.5;

            $x = $x - floor($x);
            $y = $y - floor($y);

            $x -= 0.5;
            $y -= 0.5;

            # END REPETITION

            # length
            my $d = sqrt(($x*$x) + ($y*$y));

            $d *= exp( -$d0 );

            my @color = pallete($d0 + $i * 0.4 + $t * 0.4);

            $d = sin($d * 10 + $t)/30;
            $d = abs($d);

            # step it ...
            $d = $d < 0.1 ? ($d / 0.1) : 1;
            $d = (0.03 / $d) ** 1.2;

            $final_color[0] += $color[0] * $d;
            $final_color[1] += $color[1] * $d;
            $final_color[2] += $color[2] * $d;
        }

        return (
            max( 0, min( 1.0, $final_color[0] ) ),
            max( 0, min( 1.0, $final_color[1] ) ),
            max( 0, min( 1.0, $final_color[2] ) ),
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
    #sleep(0.016);

}

$s->show_cursor;

