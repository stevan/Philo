#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use List::Util  qw[ shuffle ];
use Data::Dumper;
use Math::Trig;

use Philo;

my $HEIGHT = 80;
my $WIDTH  = 100;

class WaveAnimation {
    use Math::Trig;

    field $height :param;
    field @waves;

    method add_wave ( $type, $a, $f ) { push @waves => [ $type, $a, $f ]}

    method draw_at ( $p, $t ) {
        my $v = 0;

        foreach my $w ( @waves ) {
            my ($type, $a, $f) = @$w;
            $v -= $self->$type( $a, $f, $p->x + $t );
        }

        $v /= scalar @waves;

        return unless ceil(abs($p->y * $height)) == ceil(abs($v * $height));
        return abs($p->y) - abs($v);
    }

    method sin ( $a, $f, $t ) {
        return ($a * sin( 2 * pi * $f * $t ))
    }

    method cos ( $a, $f, $t ) {
        return ($a * cos( 2 * pi * $f * $t ))
    }
}

my $w = WaveAnimation->new( height => $HEIGHT * 0.5 );
$w->add_wave( $_, rand(2), rand )
    #foreach 'sin';
    foreach (shuffle(map { ('sin', 'cos') } (0 .. 16)));

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {


        return Philo::Color->new( r => 0.5, g => 0.5, b => 0.1 ) if $p->y > 0;

        if (my $i = $w->draw_at( $p, $t )) {
            return Philo::Color->new(
                r => 0.3,
                g => 0.3,
                b => 0.1,
            );
        }

        return Philo::Color->new( r => 0.3, g => 0.5, b => 0.8 ) if $p->y < 0;


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
    #sleep(0.03);
}

$s->show_cursor;

