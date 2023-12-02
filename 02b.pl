#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ product };

my @COLOURS = qw( red blue green );

my $sum = 0;
while (<>) {
    my ($id) = /Game ([0-9]+):/;
    s/.*://;

    my %min;
    @min{@COLOURS} = (0) x 3;

    for my $set (split /;/) {
        while ($set =~ /([0-9]+) (red|green|blue)/g) {
            my ($count, $colour) = ($1, $2);
            $min{$colour} = $count if $count > $min{$colour};
        }
    }
    $sum += product(values %min);
}
say $sum;

__DATA__
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
