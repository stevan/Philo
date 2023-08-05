
use v5.38;
use experimental qw[ class ];

class Philo::Tools::Direction {
    use constant UP    => 1;
    use constant DOWN  => 2;
    use constant RIGHT => 3;
    use constant LEFT  => 4;

    field $dir :param = LEFT;

    method to_up    { $dir = UP    ;$self }
    method to_down  { $dir = DOWN  ;$self }
    method to_right { $dir = RIGHT ;$self }
    method to_left  { $dir = LEFT  ;$self }

    method is_up    { $dir == UP    }
    method is_down  { $dir == DOWN  }
    method is_right { $dir == RIGHT }
    method is_left  { $dir == LEFT  }
    method is_vert  { $dir == UP    || $dir == DOWN }
    method is_horz  { $dir == RIGHT || $dir == LEFT }
}


__END__
