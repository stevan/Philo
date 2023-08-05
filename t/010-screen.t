#!perl

use v5.38;
use experimental qw[ class try builtin ];
use builtin      qw[ ceil floor ];

use Data::Dumper;

use Stella;
use Philo;

my $HEIGHT = 80;
my $WIDTH  = 120;

## ----------------------------------------------------------------------------
## Starfield
## ----------------------------------------------------------------------------
## This keeps track of
##   - direction of travel
##   - a set of stars in the field
## For of every star we keep track of:
##   - current position
##   - current mass
##   - curent velocity
## When a star reaches the edge, it is reclaimed and a new star
## takes it's place in the field.
## ----------------------------------------------------------------------------

class Starfield {

    field $direction; # Philo::Tools::Direction
    field %stars;     # HashRef["$x:$y"] = [ $x, $y, $m, $v ]

    field $num_stars :param;
    field $width     :param;
    field $height    :param;

    ADJUST {
        # create the stars
        foreach (0 .. $num_stars) {
            my ($x, $y) =  (int(rand($width)), int(rand($height)));
            # we key them by x/y coords ...
            $stars{"${x}:${y}"} = [ $x, $y, rand, rand ];
        }

        # set the default direction (LEFT)
        $direction = Philo::Tools::Direction->new;
    }

    method go_up    { $direction->to_up    }
    method go_down  { $direction->to_down  }
    method go_right { $direction->to_right }
    method go_left  { $direction->to_left  }

    method has_star_at      ($p) { my ($x, $y) = $p->xy; exists $stars{"${x}:${y}"} }
    method star_mass_at     ($p) { my ($x, $y) = $p->xy; $stars{"${x}:${y}"}->[2]   }
    method star_velocity_at ($p) { my ($x, $y) = $p->xy; $stars{"${x}:${y}"}->[3]   }

    method star_distance_at ($p) {
        my ($x, $y) = $p->xy;
        my $star = $stars{"${x}:${y}"};
        return ($star->[2] + $star->[3] * 10);
    }

    method move_stars {
        my @coords = keys %stars;

        my %s;
        foreach my $coord ( @coords ) {
            my $star = $stars{ $coord };

            my ($x, $y, $mass, $velocity) = @$star;

            my $momentum = $mass + $velocity * 5;
               $momentum = ceil($momentum * 0.5);

            $y += $momentum if $direction->is_up;
            $y -= $momentum if $direction->is_down;
            $x -= $momentum if $direction->is_right;
            $x += $momentum if $direction->is_left;

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

            $s{"${x}:${y}"} = $stars{ $coord };
        }

        %stars = %s;
    }
}

## ----------------------------------------------------------------------------
## Spaceship
## ----------------------------------------------------------------------------
## Keeps track of the actual sprite, its location and orientation
## ----------------------------------------------------------------------------

class Spaceship {

    # location
    field $top  :param;
    field $left :param;

    field $sprite; # the "spaceship" sprite

    ADJUST {

        # create the spite ...

        state $i; # empty

        # Eyes, Nose, Mouth
        state $e = Philo::Color->new( r => 0.1, g => 0.5, b => 0.7 );
        state $n = Philo::Color->new( r => 0.5, g => 0.1, b => 0.3 );
        state $m = Philo::Color->new( r => 0.3, g => 0.2, b => 0.1 );

        # Whiskers
        state $W = Philo::Color->new( r => 0.2, g => 0.2, b => 0.2 );

        # Dark, Medium, Light
        state $D = Philo::Color->new( r => 0.5, g => 0.3, b => 0.1 );
        state $M = Philo::Color->new( r => 0.8, g => 0.5, b => 0.1 );
        state $L = Philo::Color->new( r => 0.9, g => 0.7, b => 0.1 );

        # build the sprite
        $sprite = Philo::Sprite->new(
            top    => $top,
            left   => $left,
            bitmap => [
                [ $i,$i,$i,$i,$M,$i,$i,$i,$i,$i,$M,$i,$i,$i,$i,$i,$i,$i,$i,$i,$i,$i],
                [ $i,$i,$i,$D,$L,$D,$i,$i,$i,$D,$L,$D,$i,$i,$i,$i,$i,$i,$i,$i,$i,$i],
                [ $i,$i,$i,$M,$L,$L,$M,$D,$M,$L,$L,$L,$D,$M,$M,$D,$D,$i,$i,$i,$i,$i],
                [ $i,$i,$M,$L,$L,$L,$M,$L,$M,$L,$L,$L,$L,$M,$M,$L,$M,$M,$D,$i,$i,$i],
                [ $W,$W,$W,$L,$L,$L,$M,$L,$M,$L,$L,$L,$W,$W,$M,$L,$M,$M,$L,$D,$i,$i],
                [ $i,$i,$M,$L,$e,$L,$L,$n,$L,$L,$e,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D,$i],
                [ $W,$W,$L,$L,$L,$L,$m,$m,$m,$L,$L,$L,$W,$W,$L,$L,$L,$L,$L,$L,$M,$i],
                [ $i,$M,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D],
                [ $i,$M,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D],
                [ $i,$D,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D],
                [ $i,$i,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D,$L,$L,$M],
                [ $i,$i,$D,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D,$D,$M,$M,$L,$D,$i],
                [ $i,$i,$i,$D,$L,$L,$L,$L,$L,$L,$L,$L,$L,$L,$D,$M,$L,$M,$L,$M,$i,$i],
                [ $i,$i,$i,$i,$D,$D,$M,$M,$M,$M,$M,$M,$M,$M,$M,$D,$M,$D,$D,$i,$i,$i],
            ]
        );
    }

    method draw_at ($p) { $sprite->draw_at( $p ) }

    method go_up    { $sprite->flip   if     $sprite->is_flipped  }
    method go_down  { $sprite->flip   unless $sprite->is_flipped  }
    method go_right { $sprite->mirror unless $sprite->is_mirrored }
    method go_left  { $sprite->mirror if     $sprite->is_mirrored }
}

## ----------------------------------------------------------------------------
## Main Animation Actor
## ----------------------------------------------------------------------------

class Animation :isa(Stella::Actor) {
    use Data::Dumper;
    use Stella::Util::Debug;

    use Time::HiRes qw[ time ];
    use Term::ReadKey;

    field $height :param;
    field $width  :param;
    field $stdin  :param = \*STDIN;

    field $spaceship;       # you fly this
    field $starfield;       # though this
    field $shader;          # this draws it all
    field $animation_timer; # this manages it all

    field $logger;

    ADJUST {
        $logger = Stella::Util::Debug->logger if LOG_LEVEL;

        # Create the Spaceship Sprite
        $spaceship = Spaceship->new(
            top  => ($height / 2) - 5,
            left => ($width  / 2) - 10,
        );

        # Create the Starfield
        $starfield = Starfield->new(
            num_stars => 500,
            width     => $width,
            height    => $height,
        );

        # ... setup the shader that will draw everything
        $shader = Philo::Shader->new(
            height   => $height,
            width    => $width,
            shader   => sub ($p, $t) {
                state $VOID = Philo::Color->new( r => 0, g => 0, b => 0);

                # draw the spaceship
                if ( my $c = $spaceship->draw_at( $p ) ) {
                    return $c;
                }

                # draw stars ...
                if ( $starfield->has_star_at( $p ) ) {
                    my $s = $starfield->star_distance_at( $p );
                    return Philo::Color->new(
                        r => $s * 0.9,
                        g => $s * 0.9,
                        b => $s * 0.9,
                    );
                }

                # draw the blackness of space
                return $VOID;
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

        map { $_->go_up    } ($starfield, $spaceship) if $message eq "\e[A";
        map { $_->go_down  } ($starfield, $spaceship) if $message eq "\e[B";
        map { $_->go_right } ($starfield, $spaceship) if $message eq "\e[C";
        map { $_->go_left  } ($starfield, $spaceship) if $message eq "\e[D";
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
            $animation_timer->cancel;

            my $dur = time - $start;
            my $fps = $frames / $dur;

            say "\n\nInteruptted!";
            say "Frames: $frames time: $dur fps: $fps";
            die "Goodbye";
        };
    }

    # behavior

    method behavior {
        Stella::Behavior::Method->new( allowed => [ *Start ] );
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

