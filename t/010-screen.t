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

    use constant UP    => 1;
    use constant DOWN  => 2;
    use constant RIGHT => 3;
    use constant LEFT  => 4;

    field @speed;
    field @mass;
    field @stars;
    field @distance;

    field $freq   :param;
    field $width  :param;
    field $height :param;

    # direction specific stuff
    field $direction;
    field @indicies;
    field $limit;

    ADJUST {
        @indicies = 0 .. $width;

        @distance = map { int(rand) } @indicies;
        @speed    = map { rand } @indicies;
        @mass     = map { rand } @indicies;
        @stars    = map { $self->make_star } @indicies;

        $self->set_direction( LEFT );
    }

    method make_star { rand() > $freq ? 1 : 0 }

    method has_star_at ($x, $y) {
        $stars[$direction == UP || $direction == DOWN ? $x : $y ];
    }

    method star_distance_at ($x, $y) {
        $distance[ $direction == UP || $direction == DOWN ? $x : $y ]
    }

    method star_speed_at ($x, $y) {
        $speed[ $direction == UP || $direction == DOWN ? $x : $y ]
    }

    method star_coord_at ($x, $y) {
        return $y if $direction == UP   || $direction == DOWN;
        return $x if $direction == LEFT || $direction == RIGHT;
    }

    method set_direction ($dir) {
        $direction = $dir;

        if ($direction == UP || $direction == DOWN) {
            $limit = $height;
        }
        elsif ($direction == LEFT || $direction == RIGHT) {
            $limit = $width;
        }
        else {
            die "Unknown Direction: $direction";
        }
    }

    method move_stars {

        foreach my $i ( @indicies ) {
            if ( $stars[$i] ) {
                my $velocity = ceil( $speed[$i] + $mass[$i] * 2 );

                if ($direction == UP || $direction == LEFT) {
                    $distance[$i] += $velocity;
                }
                elsif ($direction == DOWN || $direction == RIGHT) {
                    $distance[$i] -= $velocity;
                }
                else {
                    die "Unknown Direction: $direction";
                }

                if ( $distance[$i] <= 0 ) {
                    $stars   [$i] = $self->make_star;
                    $distance[$i] = $limit;
                    $speed   [$i] = rand;
                }
                elsif ( $distance[$i] >= $limit ) {
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
    use Term::ReadKey;
    use Data::Dumper;

    field $height :param;
    field $width  :param;
    field $stdin  :param = \*STDIN;

    field $starfield;
    field $shader;
    field $animation_timer;

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
                if ( my $f = $starfield->has_star_at( $x, $y ) ) {
                    my $h = $starfield->star_distance_at( $x, $y );
                    my $s = $starfield->star_speed_at( $x, $y );

                    if ( $starfield->star_coord_at( $x, $y ) == $h ) {
                        return ( $s, $s, 1 );
                    }
                }

                # draw the blackness of space
                return ( 0.2, 0.2, 0.2 )
            }
        );
    }

    # ... methods

    method capture_keypress {
        my $message = ReadKey -1, $stdin;
        return unless $message;

        if ( $message eq "\e" ) {
            $message .= ReadKey -1, $stdin;
            $message .= ReadKey -1, $stdin;
        }

        my $direction;
        $direction = $starfield->UP    if $message eq "\e[A";
        $direction = $starfield->DOWN  if $message eq "\e[B";
        $direction = $starfield->RIGHT if $message eq "\e[C";
        $direction = $starfield->LEFT  if $message eq "\e[D";

        $starfield->set_direction( $direction );

        warn "Hey, going $direction\n";
    }

    # handlers ...

    method Start ($ctx, $message) {

        $shader->clear_screen;
        $shader->hide_cursor;

        ReadMode cbreak => $stdin;

        my $frames = 0;
        my $start  = time;

        $animation_timer = $ctx->add_interval(
            timeout  => 0.03,
            callback => sub {
                $starfield->move_stars;
                $shader->draw( time );
                $self->capture_keypress;
                $frames++;
            }
        );

        $SIG{INT} = sub {
            ReadMode restore => $stdin;
            $shader->show_cursor;

            my $dur = time - $start;
            my $fps = $frames / $dur;

            say "\n\nInteruptted!";
            say "Frames: $frames time: $dur fps: $fps";
            die "Goodbye";
        };
    }

    method Stop ($ctx, $message) {
        ReadMode restore => $stdin;
        $shader->show_cursor;
        $animation_timer->cancel;
    }

    # behavior

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



