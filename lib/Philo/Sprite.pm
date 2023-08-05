
use v5.38;
use experimental qw[ class ];

class Philo::Sprite {
    field $top    :param; # the Y coord
    field $left   :param; # the X coord
    field $bitmap :param; # Array of Array of Philo::Color objects

    # we will cache these
    field $bottom;
    field $right;

    # keep track of the sprite orientation
    field $flipped  = 0;
    field $mirrored = 0;

    ADJUST {
        $bottom = $top  + $self->height;
        $right  = $left + $self->width;
    }

    method height { scalar $bitmap->@*      }
    method width  { scalar $bitmap->[0]->@* }

    method draw_at ($p) {
        my ($x, $y) = $p->xy;
        return unless $y >= $top  && $y <= $bottom;
        return unless $x >= $left && $x <= $right;
        return $bitmap->[$y - $top]->[$x - $left];
    }

    method is_mirrored { $mirrored }
    method is_flipped  { $flipped  }

    method mirror {
        @$_ = reverse @$_ foreach $bitmap->@*;
        $mirrored = $mirrored ? 0 : 1;

    }

    method flip {
        $bitmap->@* = reverse $bitmap->@*;
        $flipped = $flipped ? 0 : 1;
    }
}

__END__
