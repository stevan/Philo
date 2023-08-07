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

        return ceil(abs($p->y * $height)) <=> ceil(abs($v * $height));
    }

    method sin ( $a, $f, $t ) {
        return ($a * sin( 2 * pi * $f * $t ))
    }

    method cos ( $a, $f, $t ) {
        return ($a * cos( 2 * pi * $f * $t ))
    }
}

my $w = WaveAnimation->new( height => $HEIGHT * 0.5 );
$w->add_wave( $_, rand(1), rand )
    foreach (shuffle(map { ('sin', 'cos') } (0 .. 4)));

my $w2 = WaveAnimation->new( height => $HEIGHT * 0.5 );
$w2->add_wave( $_, rand(2), rand )
    foreach (shuffle(map { ('sin', 'cos') } (0 .. 4)));

my $w3 = WaveAnimation->new( height => $HEIGHT * 0.5 );
$w3->add_wave( $_, rand(3), rand )
    foreach (shuffle(map { ('sin', 'cos') } (0 .. 4)));

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {
        state $ground    = Philo::Color->new( r => 0.5, g => 0.5, b => 0.1 );
        state $sky       = Philo::Color->new( r => 0.3, g => 0.5, b => 0.8 );
        state $mountain1 = Philo::Color->new( r => 0.3, g => 0.3, b => 0.2 );
        state $mountain2 = Philo::Color->new( r => 0.1, g => 0.3, b => 0.5 );
        state $mountain3 = Philo::Color->new( r => 0.1, g => 0.5, b => 0.4 );

        # waterline
        #if ($p->y > 0.01 && $p->y < 0.02) {
        #    return $ground;
        #}

        return $ground if $p->y > 0;

        my $i1 = $w->draw_at( $p, $t );
        return $mountain1 if $i1 <= 0;

        my $i2 = $w2->draw_at( $p, $t * 0.6 );
        return $mountain2 if $i2 <= 0;

        my $i3 = $w3->draw_at( $p, $t * 0.3 );
        return $mountain3 if $i3 <= 0;

        return $sky;
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

