#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $TARGET = (*ARGV::OrDATA::ORIG eq *ARGV) ? 26501365 : 5000;
warn "T: $TARGET";

my ($sy, $sx);
my @garden;
while (<>) {
    chomp;
    push @garden, [split //];
    ($sy, $sx) = ($. - 1, pos($_) - 1) if /S/g;
}
$garden[$sy][$sx] = '.';

my @MOVES = ([0, 1], [0, -1], [1, 0], [-1, 0]);
my %ACCESS;
for my $y (0 .. $#garden) {
    for my $x (0 .. $#{ $garden[0] }) {
        for my $move (@MOVES) {
            my ($ny, $nx) = ($y + $move->[0], $x + $move->[1]);
            push @{ $ACCESS{$y}{$x} }, $move
                if '.' eq $garden[ $ny % @garden ][ $nx % @{ $garden[0] } ];
        }
    }
}

my @reach = (0);
my @diff;
my @agenda = ([$sy, $sx]);
my $period = 0;

my $i = 0;
EXPANSION:
while (! $period) {
    ++$i;
    say "Expanding to $i";
    my %next;
    for my $pos (@agenda) {
        my ($y, $x) = @$pos;

        for my $move (@{ $ACCESS{ $y % @garden }{ $x % @{ $garden[0] } } }) {
            my $ny = $y + $move->[0];
            my $nx = $x + $move->[1];
            undef $next{$ny}{$nx}
        }
    }
    @agenda = ();
    for my $y (keys %next) {
        for my $x (keys %{ $next{$y} }) {
            push @agenda, [$y, $x];
        }
    }
    $reach[$i] = @agenda;
    $diff[$i]  = $reach[$i] - $reach[ $i - 1 ];

    next if $i % 50 != 0;

  PERIOD:
    for my $p (2 .. $i / 3 - 1) {
        say "Trying period $p at size $i.";
        for my $from ($i - $p .. $i) {
            next PERIOD
                if $diff[$from] - $diff[ $from - $p ]
                   != $diff[ $from - $p ] - $diff[ $from - 2 * $p ];
        }
        last PERIOD unless $p;

        say "Found $p";
        while ($i++ < 6 * $p) {
            $diff[$i] = 2 * $diff[ $i - $p ] - $diff[ $i - 2 * $p ];
            $reach[$i] = $reach[ $i - 1 ] + $diff[ $i ];
        }

        $period = $p;
        last EXPANSION
    }
}

my (@d, @d2);
for my $i (0 .. $period - 1) {
    $d2[$i] = $diff[ $i + 5 * $period ] - $diff[ 4 * $period + $i ];
    $d[$i]  = $diff[4 * $period + $i] - 4 * $d2[$i];
}

my $m = $TARGET % $period;

my $d = 0;
my $d2 = 0;
for my $j (3 * $period + $m + 1 .. 4 * $period + $m) {
    my $dd = $d[$j % $period] + $d2[$j % $period] * (1 + int($j / $period));
    $d += $dd;
    $d2 += $d2[$j % $period];
}

my $n = int(($TARGET - 4 * $period - $m - 1)/ $period) + 1;
my $s = $reach[ 4 * $period + $m ] + $d * $n + $d2 * ($n * ($n - 1) / 2);
say $s;

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
