#!perl

use v5.38;

use Test::More;
use Test::Differences;

use Philo;

subtest '... test simple Philo::Point' => sub {
    my $p1 = Philo::Point->new( x => 0, y => 0 );
    isa_ok($p1, 'Philo::Point');

    is($p1->x, 0, '... got the right x');
    is($p1->y, 0, '... got the right y');

    eq_or_diff([0,0], [$p1->xy], '... got the right xy');
    eq_or_diff([0,0], [$p1->yx], '... got the right yx');

##

    my $p2 = Philo::Point->new( x => 10, y => 5 );
    isa_ok($p2, 'Philo::Point');

    is($p2->x, 10, '... got the right x');
    is($p2->y, 5, '... got the right y');

    eq_or_diff([10,5], [$p2->xy], '... got the right xy');
    eq_or_diff([5,10], [$p2->yx], '... got the right yx');

    ok(!$p1->equals($p2), '... p1 is not equal to p2');

##

    my $sum1 = $p1->add( $p2 );
    isa_ok($sum1, 'Philo::Point');

    is($sum1->x, 10, '... got the right x');
    is($sum1->y, 5, '... got the right y');

    eq_or_diff([10,5], [$sum1->xy], '... got the right xy');
    eq_or_diff([5,10], [$sum1->yx], '... got the right yx');

    ok($sum1->equals($p2), '... sum1 is equal to p2');
    ok(!$sum1->equals($p1), '... sum1 is not equal to p1');

    ok($sum1->sub($p2)->equals($p1), '... sum1 - p2 is not equal to p1');
##

    my $sum2 = $sum1->add( $p2 );
    isa_ok($sum2, 'Philo::Point');

    is($sum2->x, 20, '... got the right x');
    is($sum2->y, 10, '... got the right y');

    eq_or_diff([20,10], [$sum2->xy], '... got the right xy');
    eq_or_diff([10,20], [$sum2->yx], '... got the right yx');

    ok(!$sum2->equals($sum1), '... sum2 is not equal to sum1');

    ok($sum2->sub($p2)->equals($sum1), '... sum2 - p2 is equal to sum1');
};



done_testing;
