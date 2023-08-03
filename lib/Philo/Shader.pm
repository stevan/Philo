
use v5.38;
use experimental qw/ class try for_list /;

$|++;

use Philo::Point;
use Philo::Color;

class Philo::Shader {
    use Carp qw/ confess /;

    field $height   :param;
    field $width    :param;
    field $shader   :param;

    use constant TOP_LEFT   => 1;
    use constant CENTERED   => 2;

    field $coord_system :param = TOP_LEFT;

    ADJUST {
        $height > 0           || confess 'The `height` must be a greater than 0';
        $width  > 0           || confess 'The `width` must be a greater than 0';
        ref $shader eq 'CODE' || confess 'The `shader` must be a CODE ref';

        $height += 1 if $height % 2 == 0;
        $width  += 1 if $width  % 2 == 0;
    }

    method clear_screen { print "\e[2J"   }
    method hide_cursor  { print "\e[?25l" }
    method show_cursor  { print "\e[?25h" }

    method draw ($t) {
        my $newline = "\e[B\e[".($width+1)."D";
        my @cols    = ( 0 .. $width  );
        my @rows    = ( 0 .. $height );

        if ($coord_system == CENTERED) {
            @cols = map { (($_ / $width ) * 2.0) - 1.0 } @cols;
            @rows = map { (($_ / $height) * 2.0) - 1.0 } @rows;
        }

        my @out;
        foreach my ($y1, $y2) ( @rows ) {
            push @out => ((map {
                my $x = $_;
                sprintf "\e[38;2;%d;%d;%d;48;2;%d;%d;%d;m▀\e" => map { 255 * $_ }
                    $shader->( $x, $y1, $t ),
                    $shader->( $x, $y2, $t )
                } @cols),
            $newline);
        }

        print join '' => ("\e[H", @out, "\e[0m");

    }

}

__END__
