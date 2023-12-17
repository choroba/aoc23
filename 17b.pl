#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };

use constant {  # Use 1, 3 to solve Part 1.
    MIN_STRAIGHT => 4,
    MAX_STRAIGHT => 10,
};

my @DIRECTIONS = ([0, 1], [1, 0], [-1, 0], [0, -1]);

my @map;
while (<>) {
    chomp;
    push @map, [split //];
}

# heat[y][x][dir][straight]
my @heat;
$heat[0][0][2][ MAX_STRAIGHT - 1 ] = 0;
$heat[0][0][3][ MAX_STRAIGHT - 1 ] = 0;

while (1) {
    my $change;
    for my $y (0 .. $#map) {
        for my $x (0 .. $#{ $map[0] }) {
            next unless $heat[$y][$x];

            for my $d_out (0 .. $#DIRECTIONS) {
                my $direction_out = $DIRECTIONS[$d_out];
                my $ny = $y + $direction_out->[0];
                my $nx = $x + $direction_out->[1];
                next if $ny < 0 || $ny > $#map
                     || $nx < 0 || $nx > $#{ $map[0] };

                for my $d_in (0 .. $#DIRECTIONS) {
                    my $direction_in = $DIRECTIONS[$d_in];
                    next if $direction_in->[0] == -$direction_out->[0]
                         && $direction_in->[1] == -$direction_out->[1];

                    if ($d_in == $d_out) {
                        for my $s (1 .. MAX_STRAIGHT - 1) {
                            next unless $heat[$y][$x][$d_out][$s - 1];

                            my $h = $heat[$y][$x][$d_in][$s - 1]
                                  + $map[$ny][$nx];
                            ++$change, $heat[$ny][$nx][$d_out][$s] = $h
                                if ! defined $heat[$ny][$nx][$d_out][$s]
                                || $h < $heat[$ny][$nx][$d_out][$s];
                        }
                    } else {
                        my $best = min(grep defined,
                                       @{ $heat[$y][$x][$d_in] // [] }[
                                           MIN_STRAIGHT - 1 .. MAX_STRAIGHT - 1
                                       ]);
                        next unless defined $best;

                        my $h = $map[$ny][$nx] + $best;
                        ++$change, $heat[$ny][$nx][$d_out][0] = $h
                            if ! defined $heat[$ny][$nx][$d_out][0]
                            || $h < $heat[$ny][$nx][$d_out][0];
                    }
                }
            }
        }
    }
    last unless $change;
}

say min(grep defined,
        map @{ $_ // [] }[MIN_STRAIGHT - 1 .. MAX_STRAIGHT - 1],
        @{ $heat[$#map][ $#{ $map[0] } ] });

__DATA__
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
