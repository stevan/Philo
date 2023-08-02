#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Time::HiRes qw[ sleep time ];
use Data::Dumper;

use Philo;

my $HEIGHT = 60;
my $WIDTH  = 80;

class StarField {
    field @indicies;

    field @speed;
    field @mass;
    field @stars;
    field @distance;

    field $freq   :param;
    field $width  :param;
    field $height :param;

    ADJUST {
        @indicies = 0 .. $width;

        @distance = map { int(rand) } @indicies;
        @speed    = map { rand } @indicies;
        @mass     = map { rand } @indicies;
        @stars    = map {
            $_ % 2 == 0
                ? $self->make_star
                : 0
        } @indicies;
    }

    method make_star { rand() > $freq ? 1 : 0 }

    method has_star_at      ($i) { $stars   [$i] }
    method star_distance_at ($i) { $distance[$i] }
    method star_speed_at    ($i) { $speed   [$i] }

    method move_stars {
        foreach my $i (@indicies) {
            if ( $stars[$i] ) {
                $distance[$i] += ceil( $speed[$i] + $mass[$i] * 2 );

                if ( $distance[$i] >= $width ) {
                    $stars   [$i] = $self->make_star;
                    $distance[$i] = 0;
                    $speed   [$i] = rand;
                }
            }
            else {
                $stars[$i] = $self->make_star;
            }
        }
    }

}

my $starfield = StarField->new( freq => 0.9, width => $WIDTH + 1, height => $HEIGHT + 1 );

my $s = Philo::Shader->new(
    height   => $HEIGHT,
    width    => $WIDTH,
    shader   => sub ($x, $y, $t) {
        state $center_x = int($WIDTH  / 2);
        state $center_y = int($HEIGHT / 2);

        if ($x == 0 && $y == 0) {
            $starfield->move_stars;
        }

        my $xd = abs($center_x - $x);
        my $yd = abs($center_y - $y);

        # pink middle fin
        if ( abs($center_x - $x + 4) < 2 && $yd < 1 ) {
            return (0.9,0.4,0.6);
        }
        # main body
        elsif ( $xd < 6 && $yd < 2 ) {
            return (0.6,0.6,0.9);
        }
        # pink side fin
        elsif ( abs($center_x - $x + 4) < 2 && $yd < 3 ) {
            return (0.9,0.4,0.6);
        }
        # grey part before nose
        elsif ( abs($center_x - $x - 2) < 8 && $yd < 2 ) {
            return (0.3,0.4,0.6);
        }
        # grey nose
        elsif ( abs($center_x - $x - 5) < 8 && $yd < 1 ) {
            return (0.3,0.4,0.6);
        }
        # yellow windows
        elsif ( abs($center_x - $x - 3) < 9 && $yd < 2 ) {
            return (0.9,0.7,0.3);
        }




        #elsif ( $xd < 4 && $yd < 2 ) {
        #    return (1,0.7,0.3);
        #}
        #elsif ( abs($center_x - $x + 1) < 3 && $yd < 3 ) {
        #    return (0.7,0.9,1);
        #}
        #elsif ( $xd < 5 && $yd < 2 ) {
        #    return (1,0.3,0.5);
        #}
        #elsif ( abs($center_x - $x + 2) < 2 && $yd < 4 ) {
        #    return (1,1,0.3);
        #}

        if ( my $f = $starfield->has_star_at( $y ) ) {
            my $h = $starfield->star_distance_at( $y );
            my $s = $starfield->star_speed_at( $y );

            if ( $x == $h ) {
                return ( $s, $s, 1 );
            }
        }

        return (
            0,
            0,
            0
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
    sleep(0.01);
}

$s->show_cursor;

