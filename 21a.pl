#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my ($sy, $sx);
my @garden;
while (<>) {
    chomp;
    push @garden, [split //];
    ($sy, $sx) = ($. - 1, pos($_) - 1) if /S/g;
}
$garden[$sy][$sx] = '.';

my @MOVES = ([0, 1], [0, -1], [1, 0], [-1, 0]);
my @agenda = ([$sy, $sx]);
my $reach = 0;
for (1 .. 64) {
    my %next;
    for my $pos (@agenda) {
        my ($y, $x) = @$pos;

        for my $move (@MOVES) {
            my ($ny, $nx) = ($y + $move->[0], $x + $move->[1]);
            undef $next{$ny}{$nx} if $ny >= 0 && $ny <= $#garden
                                  && $nx >= 0 && $nx <= $#{ $garden[0] }
                                  && $garden[$ny][$nx] eq '.';
        }
    }
    @agenda = ();
    for my $y (keys %next) {
        for my $x (keys %{ $next{$y} }) {
            push @agenda, [$y, $x];
        }
    }
}

say scalar @agenda;

__DATA__
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
