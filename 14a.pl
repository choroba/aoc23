#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @dish;
while (my $line = <>) {
    chomp $line;
    push @dish, [split //, $line];
}

for my $y (0 .. $#dish) {
    for my $x (0 .. $#{ $dish[0] }) {
        if ('O' eq $dish[$y][$x]) {
            my $yy = $y - 1;
            while ($yy >= 0  && $dish[$yy][$x] eq '.') {
                $dish[$yy][$x] = 'O';
                $dish[ $yy-- + 1 ][$x] = '.';
            }
        }
    }
}

my $load = 0;
for my $y (0 .. $#dish) {
    $load += (@dish - $y) * grep 'O' eq $_, @{ $dish[$y] };
}
say $load;

__DATA__
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
