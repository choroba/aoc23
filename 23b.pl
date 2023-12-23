#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ first };

my @MOVES  = ([0, 1], [1, 0], [0, -1], [-1, 0]);
my @map;
while (<>) {
    chomp;
    push @map, [split //];
}
my $x = first { '.' eq $map[0][$_] } 0 .. $#{ $map[0] };

my @n = (["n0_$x", 1, $x, 1]);
my %visited = ("n0_$x 0 $x" => undef);
my %edges;
while (my $n = shift @n) {
    my ($from, $y, $x, $l) = @$n;
    my @steps;
    for my $move (@MOVES) {
        my $ny = $y + $move->[0];
        my $nx = $x + $move->[1];
        next if '#' eq $map[$ny][$nx] || exists $visited{"$from $ny $nx"};

        if ($ny == $#map) {
            $edges{$from}{"n$ny\_$nx"} = $l + 1;
            $edges{"n$ny\_$nx"}{$from} = $l + 1;
        } else {
            push @steps, [$ny, $nx];
        }
    }
    undef $visited{"$from $y $x"};
    if (@steps == 1) {
        push @n, [$from, @{ $steps[0] }, $l + 1];

    } elsif (@steps) {
        $edges{$from}{"n$y\_$x"} = $l;
        $edges{"n$y\_$x"}{$from} = $l;
        undef $visited{"n$y\_$x $y $x"};
        push @n, map ["n$y\_$x", @$_, 1], @steps;
    }
}

my $max = 0;
my %at;
my @agenda = (["n0_$x", {}, 0]);
while (my $ag = shift @agenda) {
    my ($node, $visited, $length) = @$ag;
    for my $neighbour (keys %{ $edges{$node} }) {
        my $nl = $length + $edges{$node}{$neighbour};
        if ($neighbour =~ /n$#map\_/) {
            $max = $nl if $nl > $max;

        } else {
            push @agenda, [$neighbour, {%$visited, $node => undef}, $nl]
                unless exists $visited->{$neighbour};
        }
    }
}
say $max;

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
