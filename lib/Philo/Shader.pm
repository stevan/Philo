
use v5.38;
use experimental qw[ class for_list ];

$|++;

use Philo::Point;
use Philo::Color;

class Philo::Shader {
    use Carp qw[ confess ];

    field $height   :param;
    field $width    :param;
    field $shader   :param;

    field %coords;
    field $newline;
    field @cols;
    field @rows;

    use constant TOP_LEFT => 1;
    use constant CENTERED => 2;

    field $coord_system :param = TOP_LEFT;

    ADJUST {
        $height > 0           || confess 'The `height` must be a greater than 0';
        $width  > 0           || confess 'The `width` must be a greater than 0';
        ref $shader eq 'CODE' || confess 'The `shader` must be a CODE ref';

        $height -= 1 if $height % 2 == 0;
        $width  -= 1 if $width  % 2 == 0;

        $newline = "\e[B\e[".($width+1)."D";

        if ($coord_system == TOP_LEFT) {
            @cols = ( 0 .. $width  );
            @rows = ( 0 .. $height );
        }
        elsif ($coord_system == CENTERED) {
            @cols = map { (($_ / $width ) * 2.0) - 1.0 } ( 0 .. $width  );
            @rows = map { (($_ / $height) * 2.0) - 1.0 } ( 0 .. $height );
        }
        else {
            confess "Unknown Coord System: $coord_system";
        }

        foreach my $y ( @rows ) {
            foreach my $x ( @cols ) {
                $coords{"${x}:${y}"} = Philo::Point->new( x => $x, y => $y );
            }
        }
    }

    method rows { $height }
    method cols { $width  }

    my $RESET       = "\e[0m";
    my $HOME_CURSOR = "\e[H";

    method clear_screen       { print "\e[2J"      }
    method hide_cursor        { print "\e[?25l"    }
    method show_cursor        { print "\e[?25h"    }
    method home_cursor        { print $HOME_CURSOR }
    method enable_alt_buffer  { print "\e[?1049h"  }
    method disable_alt_buffer { print "\e[?1049l"  }

    method draw ($t) {

        my @out;
        foreach my ($y1, $y2) ( @rows ) {
            push @out => ((map {
                my $x = $_;
                sprintf "\e[38;2;%d;%d;%d;48;2;%d;%d;%d;m▀\e" => map { 255 * $_ }
                    $shader->( $coords{"${x}:${y1}"}, $t )->rgb,
                    $shader->( $coords{"${x}:${y2}"}, $t )->rgb,
                } @cols),
            $newline);
        }

        print join '' => ($HOME_CURSOR, @out, $RESET);
    }

}

__END__
