#!perl

use v5.38;

use Test::More;
use Test::Differences;

use Philo;

subtest '... test simple Philo::Color' => sub {

    my $red   = Philo::Color->new( r => 1, g => 0, b => 0 );
    my $green = Philo::Color->new( r => 0, g => 1, b => 0 );
    my $blue  = Philo::Color->new( r => 0, g => 0, b => 1 );

    isa_ok($red,   'Philo::Color');
    isa_ok($green, 'Philo::Color');
    isa_ok($blue,  'Philo::Color');

    is($red->r, 1, '... Red r is 1');
    is($red->g, 0, '... Red g is 0');
    is($red->b, 0, '... Red b is 0');

    eq_or_diff([1,0,0],[$red->rgb],   '... Red has the right rgb');
    eq_or_diff([0,1,0],[$green->rgb], '... Green has the right rgb');
    eq_or_diff([0,0,1],[$blue->rgb],  '... Blue has the right rgb');

    ok(!$red->equals($green), '... red does not equal green');
    ok(!$blue->equals($red), '... blue does not equal red');

    ok($red->equals($red), '... red equals red');

    ok($green->equals(Philo::Color->new( r => 0, g => 1, b => 0 )), '... green equals Color(0,1,0)');

};



done_testing;
