#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use Data::Dumper;

use Philo;
use Philo::Tools::Shaders;

my $HEIGHT = 60;
my $WIDTH  = 120;

class Wave {
    use Math::Trig;

    field $frequency :param;
    field $amplitude :param;
    field $function  :param;

    field $f;

    ADJUST {
        no strict 'refs';
        $f = \&{"CORE::${function}"};
    }

    method calculate_at ($p, $t=0) {
        ($amplitude * $f->( 2 * pi * $frequency * $p + $t));
    }
}

class MountainRange {

    field $height :param;
    field $waves  :param;

    method draw_at ( $p, $t ) {
        my $v = 0;

        foreach my $w ( @$waves ) {
            $v -= $w->calculate_at( $p->x + $t );
        }

        $v /= scalar @$waves;

        return ($p->y * $height) - ($v * $height);
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

        state $mtn1 = MountainRange->new(
            height => $HEIGHT * 0.5,
            waves  => [
                Wave->new( frequency => 0.9, amplitude => 0.2, function => 'sin' ),
                Wave->new( frequency => 1.5, amplitude => 0.1, function => 'cos' ),
                Wave->new( frequency => 0.3, amplitude => 0.3, function => 'sin' ),
                Wave->new( frequency => 1.2, amplitude => 0.2, function => 'sin' ),
            ]
        );

        state $mtn2 = MountainRange->new(
            height => $HEIGHT * 0.5,
            waves  => [
                Wave->new( frequency => 0.3, amplitude => 0.5, function => 'cos' ),
                Wave->new( frequency => 0.7, amplitude => 0.7, function => 'sin' ),
                Wave->new( frequency => 0.5, amplitude => 0.8, function => 'sin' ),
            ]
        );

        state $mtn3 = MountainRange->new(
            height => $HEIGHT * 0.5,
            waves  => [
                Wave->new( frequency => 3.0, amplitude => 0.9, function => 'sin' ),
                Wave->new( frequency => 2.0, amplitude => 1.2, function => 'cos' ),
                Wave->new( frequency => 1.3, amplitude => 0.9, function => 'sin' ),
            ]
        );

        state $w1 = Wave->new( function  => 'cos', amplitude => 0.2, frequency => 2 );

        # road stripes
        if ( $p->y > 0.55 && $p->y < 0.57 ) {
            my $v = $w1->calculate_at( $p->x + $t );
               $v = smoothstep( 0.15, 0.10, abs($v) );
               $v = clamp( 0.1, 1, $v );

            return Philo::Color->new( r => $v, g => $v, b => clamp( 0.2, 1, $v ) );
        }

        return $road   if $p->y > 0.40 && $p->y < 0.73;
        return $ground if $p->y > 0.25;

        my $mtn1_y = $mtn1->draw_at( $p, $t * 0.6 );
        my $mtn2_y = $mtn2->draw_at( $p, $t * 0.4 );
        my $mtn3_y = $mtn3->draw_at( $p, $t * 0.2 );

        return Philo::Color->new( r => 0.3, g => 0.3, b => 0.2 ) if $mtn1_y > $p->y;
        return Philo::Color->new( r => 0.1, g => 0.3, b => 0.5 ) if $mtn2_y > $p->y;
        return Philo::Color->new( r => 0.1, g => 0.5, b => 0.4 ) if $mtn3_y > $p->y;

        return $sky;
    }
);

sub run_shader ($s, $delay=undef) {

    my $frames = 0;
    my $start  = time;

    $SIG{INT} = sub {
        $s->show_cursor;
        #$s->disable_alt_buffer;
        die "Interuptted!";
    };

    $s->clear_screen;
    $s->hide_cursor;
    $s->enable_alt_buffer;

    my $t = 0;
    while (1) {
        my $t = time;
        $s->draw( $t );
        sleep( $delay ) if $delay;
        my $d = (time() - $t);
        say "frame    : " . $frames++;
        say "fps      : " . $frames / ($t - $start);
        say "duration : " . $d;
        say "elapsed  : " . ($t - $start);
    }

    $s->show_cursor;
    $s->disable_alt_buffer;
}

run_shader( $s );


