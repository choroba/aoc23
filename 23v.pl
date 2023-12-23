#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

# Draw the graph of crossroads in the map.

use ARGV::OrDATA;
use List::Util qw{ first };

my @MOVES  = ([0, 1], [1, 0], [0, -1], [-1, 0]);
my @map;
while (<>) {
    chomp;
    push @map, [split //];
}
my $x = first { '.' eq $map[0][$_] } 0 .. $#{ $map[0] };

open my $dot, '|-', qw{ dot -T x11 } or die $!;
say {$dot} 'strict graph {';
say {$dot} "n0_$x [color=blue;shape=rectangle]";

my @n = (["n0_$x", 1, $x, 1]);
my %visited = ("n0_$x 0 $x" => 1);
while (my $n = shift @n) {
    my ($from, $y, $x, $l) = @$n;
    my @steps;
    for my $move (@MOVES) {
        my $ny = $y + $move->[0];
        my $nx = $x + $move->[1];
        next if '#' eq $map[$ny][$nx] || $visited{"$from $ny $nx"};
        if ($ny == $#map) {
            say {$dot} "n$ny\_$nx [color=red;shape=rectangle]";
            say {$dot} "$from -- n$ny\_$nx \[label=", $l + 1, ']';
        } else {
            push @steps, [$ny, $nx];
        }
    }
    $visited{"$from $y $x"} = 1;
    if (@steps == 1) {
        push @n, [$from, @{ $steps[0] }, $l + 1];
    } elsif (@steps) {
        say {$dot} "$from -- n$y\_$x \[label=$l]";
        $visited{"n$y\_$x $y $x"} = 1;
        push @n, map ["n$y\_$x", @$_, 1], @steps;
    }
}
say {$dot} '}';

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
