#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

# Chart of the maximal length and number of remaining states to
# explore.

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
my %visited = ("n0_$x 0 $x" => 1);
my %edges;
while (my $n = shift @n) {
    my ($from, $y, $x, $l) = @$n;
    my @steps;
    for my $move (@MOVES) {
        my $ny = $y + $move->[0];
        my $nx = $x + $move->[1];
        next if '#' eq $map[$ny][$nx] || $visited{"$from $ny $nx"};
        if ($ny == $#map) {
            $edges{$from}{"n$ny\_$nx"} = $l + 1;
            $edges{"n$ny\_$nx"}{$from} = $l + 1;
        } else {
            push @steps, [$ny, $nx];
        }
    }
    $visited{"$from $y $x"} = 1;
    if (@steps == 1) {
        push @n, [$from, @{ $steps[0] }, $l + 1];
    } elsif (@steps) {
        $edges{$from}{"n$y\_$x"} = $l;
        $edges{"n$y\_$x"}{$from} = $l;
        $visited{"n$y\_$x $y $x"} = 1;
        push @n, map ["n$y\_$x", @$_, 1], @steps;
    }
}

open my $gp, '|-', 'gnuplot' or die $!;
say {$gp} 'set term png; set output "23b.png";';
print {$gp} 'plot "-" u 0:1 w steps title "max length",';
say {$gp} '"" u 0:($2/1000) w steps title "K states to check";';
my $max = 0;
my %at;
my @agenda = (["n0_$x", {}, 0]);
my @plot;
while (my $ag = shift @agenda) {
    my ($node, $visited, $length) = @$ag;
    for my $neighbour (keys %{ $edges{$node} }) {
        my $nl = $length + $edges{$node}{$neighbour};
        if ($neighbour =~ /n$#map\_/) {
            if ($nl > $max) {
                $max = $nl;
                push @plot, [$max, scalar @agenda];
            }

        } else {
            push @agenda, [$neighbour, {%$visited, $node => undef}, $nl]
                unless exists $visited->{$neighbour};
        }
    }
}
say {$gp} "@$_" for @plot;
say {$gp} 'e';
say {$gp} "@$_" for @plot;
say {$gp} 'e';
close $gp;


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
