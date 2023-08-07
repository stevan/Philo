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

    method calculate_at ($p) {
        ($amplitude * $f->( 2 * pi * $frequency * $p ));
    }
}

class MountainRange {

    field $height :param;
    field $color  :param;
    field $waves  :param;


    method draw_at ( $p, $t ) {
        my $v = 0;

        foreach my $w ( @$waves ) {
            $v -= $w->calculate_at( ($p->x + $t) );
        }

        $v /= scalar @$waves;

        return if ceil(($p->y * $height)) <= ceil(($v * $height));
        return $color;
    }
}

my $s = Philo::Shader->new(
    coord_system => Philo::Shader->CENTERED,
    height       => $HEIGHT,
    width        => $WIDTH,
    shader       => sub ($p, $t) {
        state $ground = Philo::Color->new( r => 0.5, g => 0.5, b => 0.1 );
        state $sky    = Philo::Color->new( r => 0.3, g => 0.5, b => 0.8 );
        state $road   = Philo::Color->new( r => 0.1, g => 0.1, b => 0.2 );
        state $stripe = Philo::Color->new( r => 0.8, g => 0.8, b => 0.8 );

        state $m1 = MountainRange->new(
            height => $HEIGHT * 0.5,
            color  => Philo::Color->new( r => 0.3, g => 0.3, b => 0.2 ),
            waves  => [
                Wave->new( frequency => 1.0, amplitude => 0.2, type => 'sin' ),
                Wave->new( frequency => 2.0, amplitude => 0.1, type => 'cos' ),
                Wave->new( frequency => 0.3, amplitude => 0.5, type => 'sin' ),
                Wave->new( frequency => 1.2, amplitude => 0.2, type => 'sin' ),
            ]
        );

        state $m2 = MountainRange->new(
            height => $HEIGHT * 0.5,
            color  => Philo::Color->new( r => 0.1, g => 0.3, b => 0.5 ),
            waves  => [
                Wave->new( frequency => 3.0, amplitude => 0.2, type => 'cos' ),
                Wave->new( frequency => 2.0, amplitude => 0.5, type => 'cos' ),
                Wave->new( frequency => 1.3, amplitude => 0.3, type => 'sin' ),
            ]
        );

        state $m3 = MountainRange->new(
            height => $HEIGHT * 0.5,
            color  => Philo::Color->new( r => 0.1, g => 0.5, b => 0.4 ),
            waves  => [
                Wave->new( frequency => 3.0, amplitude => 0.9, type => 'cos' ),
                Wave->new( frequency => 2.0, amplitude => 0.9, type => 'cos' ),
                Wave->new( frequency => 1.3, amplitude => 0.9, type => 'sin' ),
            ]
        );

        return $stripe if $p->y > 0.55 && $p->y < 0.57;
        return $road   if $p->y > 0.40 && $p->y < 0.72;

        return $ground if $p->y > 0.25;

        if ( my $c = $m1->draw_at( $p, $t       ) ) { return $c }
        if ( my $c = $m2->draw_at( $p, $t * 0.3 ) ) { return $c }
        if ( my $c = $m3->draw_at( $p, $t * 0.1 ) ) { return $c }

        return $sky;
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
        my $d = (time() - $t);
        say "avg fps  : " . $frames / ($t - $start);
        say "cur fps  : " . (1 / $d);
        say "duration : " . $d;
        say "frames   : " . $frames++;
        say "now      : " . $t;
        sleep( $delay ) if $delay;
    }

    $s->show_cursor;
}

run_shader( $s );


