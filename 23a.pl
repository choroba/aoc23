#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use List::Util qw{ first max };

my @MOVES  = ([0, 1], [1, 0], [0, -1], [-1, 0]);
my %SLOPES = qw( > 0 v 1 < 2 ^ 3 );

my @map;

sub search($y, $x, %visited) {
    my @paths;
    for my $move_index (0 .. $#MOVES) {
        next if '.' ne $map[$y][$x] && $SLOPES{ $map[$y][$x] } != $move_index;

        my $move = $MOVES[$move_index];
        my $ny = $y + $move->[0];
        my $nx = $x + $move->[1];
        next if '#' eq $map[$ny][$nx] || exists $visited{"$ny $nx"};

        return scalar keys %visited if $ny == $#map;

        no warnings 'recursion';
        push @paths, search($ny, $nx, %visited, "$ny $nx" => undef);
    }
    return @paths
}

while (<>) {
    chomp;
    push @map, [split //];
}

my $x = first { '.' eq $map[0][$_] } 0 .. $#{ $map[0] };
say max(search(0, $x, ("0 $x" => undef)));

__DATA__
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
