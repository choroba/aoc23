#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %BAG = (red => 12, green => 13, blue => 14);

my $sum = 0;
GAME:
while (<>) {
    my ($id) = /Game ([0-9]+):/;
    s/.*://;

    for my $set (split /;/) {
        for my $color (keys %BAG) {
            next GAME if $set =~ /([0-9]+) $color/ && $1 > $BAG{$color};
        }
    }
    $sum += $id;
}
say $sum;

__DATA__
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
