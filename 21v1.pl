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

open my $gnuplot, '|-', 'gnuplot' or die $!;
say {$gnuplot} 'set term png size 640,480;',
               'set output "21-1.png";',
               'plot "-" w lines title "r_{i+1}-r_i";';

for my $i (1 .. 500) {
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
    say {$gnuplot} "$diff[$i]";
}

say {$gnuplot} 'e';
close $gnuplot;

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
