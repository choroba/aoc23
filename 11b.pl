#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

use constant EXPANSION => 1_000_000 - 1;

my @galaxies;
my $line = 0;
my $width;

while (<>) {
    chomp;
    $width //= length;
    my $pos = -1;
    while (do { $pos = index $_, '#', $pos + 1; $pos >= 0 }) {
        push @galaxies, [$line, $pos];
    }
    $line += EXPANSION unless /#/;
    ++$line;
}

my %column;
@column{ 0 .. $width - 1 } = ();
delete @column{ map $_->[1], @galaxies };
for my $empty (sort { $b <=> $a } keys %column) {
    $_->[1] > $empty and $_->[1] += EXPANSION for @galaxies;
}

my $sum = 0;
for my $g1 (0 .. $#galaxies - 1) {
    for my $g2 ($g1 + 1 .. $#galaxies) {
        my $distance = abs($galaxies[$g1][0] - $galaxies[$g2][0])
                     + abs($galaxies[$g1][1] - $galaxies[$g2][1]);
        $sum += $distance;
    }
}

say $sum;

__DATA__
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
