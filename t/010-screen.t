#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Data::Dumper;

use Stella;
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

class Animation :isa(Stella::Actor) {
    use Test::More;
    use Stella::Util::Debug;

    use Time::HiRes qw[ sleep time ];
    use Data::Dumper;

    field $height :param;
    field $width  :param;

    field $starfield;
    field $shader;
    field $animation_timer;
    field $input_watcher;

    field $logger;

    ADJUST {
        $logger = Stella::Util::Debug->logger if LOG_LEVEL;

        $starfield = StarField->new(
            freq   => 0.9,
            width  => $width  + 1,
            height => $height + 1,
        );

        $shader = Philo::Shader->new(
            height   => $height,
            width    => $width,
            shader   => sub ($x, $y, $t) {
                # --------------------------------------------------
                # BEGIN DRAW SHIP
                # --------------------------------------------------

                state $center_x = int($width  / 2);
                state $center_y = int($height / 2);

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

                # --------------------------------------------------
                # END DRAW SHIP
                # --------------------------------------------------

                # draw stars ...
                if ( my $f = $starfield->has_star_at( $y ) ) {
                    my $h = $starfield->star_distance_at( $y );
                    my $s = $starfield->star_speed_at( $y );

                    if ( $x == $h ) {
                        return ( $s, $s, 1 );
                    }
                }

                # draw the blackness of space
                return ( 0, 0, 0 )
            }
        );
    }

    method Start ($ctx, $message) {

        $shader->clear_screen;
        $shader->hide_cursor;

        #$input_watcher = $ctx->add_watcher(
        #    fh       => \*STDIN,
        #    poll     => 'r',
        #    callback => sub ($fh) {
        #    }
        #);

        my $frames = 0;
        my $start  = time;

        $animation_timer = $ctx->add_interval(
            timeout  => 0.03,
            callback => sub {
                $starfield->move_stars;
                $shader->draw( time );
                $frames++;
            }
        );

        $SIG{INT} = sub {
            my $dur = time - $start;
            my $fps = $frames / $dur;
            $shader->show_cursor;

            say "\n\nInteruptted!";
            say "Frames: $frames time: $dur fps: $fps";
            die "Goodbye";
        };
    }

    method Stop ($ctx, $message) {
        $shader->show_cursor;
        $animation_timer->cancel;
    }

    method behavior {
        Stella::Behavior::Method->new( allowed => [ *Start, *Stop ] );
    }
}

sub init ($ctx) {
    my $Animation = $ctx->spawn( Animation->new( height => $HEIGHT, width => $WIDTH ) );
    $ctx->send( $Animation, Stella::Event->new( symbol => *Animation::Start ) );
}

# -----------------------------------------------------------------------------
# Lets-ago!
# -----------------------------------------------------------------------------

Stella::ActorSystem->new( init => \&init )->loop;



