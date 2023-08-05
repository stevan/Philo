
use v5.38;
use experimental qw[ class ];

class Philo::Sprite {
    field $top    :param;
    field $left   :param;
    field $bitmap :param;

    field $bottom;
    field $right;

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

    method mirror {
        @$_ = reverse @$_ foreach $bitmap->@*;
    }

    method flip {
        $bitmap->@* = reverse $bitmap->@*;
    }
}

__END__
