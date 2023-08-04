#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Data::Dumper;

use Stella;
use Philo;

my $HEIGHT = 80;
my $WIDTH  = 120;

class StarField {

    use constant UP    => 1;
    use constant DOWN  => 2;
    use constant RIGHT => 3;
    use constant LEFT  => 4;

    field $direction;
    field %stars;

    field $num_stars :param;
    field $width     :param;
    field $height    :param;

    ADJUST {
        foreach (0 .. $num_stars) {
            my ($x, $y) =  (int(rand($width)), int(rand($height)));
            $stars{"${x}:${y}"} = [ $x, $y, rand, rand ];
        }

        $self->set_direction( LEFT );
    }

    method set_direction ($dir) { $direction = $dir }

    method has_star_at      ($x, $y) { exists $stars{"${x}:${y}"} }
    method star_distance_at ($x, $y) { $stars{"${x}:${y}"}->[2]   }

    method move_stars {
        my @coords = keys %stars;

        foreach my $coord ( @coords ) {
            my $star = $stars{ $coord };

            my ($x, $y, $mass, $velocity) = @$star;

            my $momentum = $mass + $velocity * 10;
               $momentum = ceil($momentum * 0.5);

            $y += $momentum if $direction == UP;
            $y -= $momentum if $direction == DOWN;
            $x -= $momentum if $direction == RIGHT;
            $x += $momentum if $direction == LEFT;

            my $reset;

               if ( $x < 0       ) { $x = $width;  $reset++; }
            elsif ( $x > $width  ) { $x = 0;       $reset++; }
               if ( $y < 0       ) { $y = $height; $reset++; }
            elsif ( $y > $height ) { $y = 0;       $reset++; }

            $star->[0] = $x;
            $star->[1] = $y;
            if ($reset) {
                $star->[2] = rand;
                $star->[3] = rand;
            }

            $stars{"${x}:${y}"} = delete $stars{ $coord };
        }
    }
}

class Sprite {

    field $bitmap :param;

    field $top    :param;
    field $left   :param;
    field $bottom :param;
    field $right  :param;

    method height { $bottom - $top }
    method width  { $right - $left }

    method draw_at ($x, $y) {
        return unless $y >= $top  && $y <= $bottom;
        return unless $x >= $left && $x <= $right;
        return $bitmap->[$y - $top]->[$x - $left];
    }
}

class Animation :isa(Stella::Actor) {
    use Test::More;
    use Stella::Util::Debug;

    use Time::HiRes qw[ time ];
    use List::Util  qw[ shuffle ];
    use Term::ReadKey;
    use Data::Dumper;

    field $height :param;
    field $width  :param;
    field $stdin  :param = \*STDIN;

    field $spaceship;
    field $starfield;
    field $shader;
    field $animation_timer;

    field $logger;

    ADJUST {
        $logger = Stella::Util::Debug->logger if LOG_LEVEL;

        $spaceship = Sprite->new(
            top    => ($height / 2) - 5,
            left   => ($width  / 2) - 5,
            bottom => ($height / 2) + 5,
            right  => ($width  / 2) + 5,
            bitmap => [
                map {
                    [map { [$_,$_*0.5,$_*0.6] } map { rand } 0 .. 10 ]
                } 0 .. 10
            ]
        );

        $starfield = StarField->new(
            num_stars => 120,
            width     => $width,
            height    => $height,
        );

        $shader = Philo::Shader->new(
            height   => $height,
            width    => $width,
            shader   => sub ($x, $y, $t) {

                if ( my $c = $spaceship->draw_at( $x, $y ) ) {
                    return @$c;
                }

                # draw stars ...
                if ( $starfield->has_star_at( $x, $y ) ) {
                    my $s = $starfield->star_distance_at( $x, $y );
                    return ( $s, $s, $s );
                }
                # draw the blackness of space
                return (0,0,0)
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



__END__

