#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

my %DIRECTION = (R => [ 0,  1],
                 L => [ 0, -1],
                 U => [-1,  0],
                 D => [ 1,  0]);

sub fill($y, $x, $lagoon, $ymin, $ymax, $xmin, $xmax) {
    no warnings 'recursion';
    $lagoon->{$y}{$x} = 1;
    fill($y - 1, $x, $lagoon, $ymin, $ymax, $xmin, $xmax)
        if $y > $ymin && ! exists $lagoon->{$y - 1}{$x};
    fill($y, $x - 1, $lagoon, $ymin, $ymax, $xmin, $xmax)
        if $x > $xmin  && ! exists $lagoon->{$y}{$x - 1};
    fill($y + 1, $x, $lagoon, $ymin, $ymax, $xmin, $xmax)
        if $y < $ymax  && ! exists $lagoon->{$y + 1}{$x};
    fill($y, $x + 1, $lagoon, $ymin, $ymax, $xmin, $xmax)
        if $x < $xmax  && ! exists $lagoon->{$y}{$x + 1};
}

my %lagoon;
my ($x, $y) = (0, 0);
my ($xmin, $xmax, $ymin, $ymax) = (0, 0, 0, 0);
while (<>) {
    my ($direction, $distance) = split ' ';
    for my $step (1 .. $distance) {
        $y += $DIRECTION{$direction}[0];
        $x += $DIRECTION{$direction}[1];
        $lagoon{$y}{$x} = 1;
        $xmin = $x if $x < $xmin;
        $ymin = $y if $y < $ymin;
        $xmax = $x if $x > $xmax;
        $ymax = $y if $y > $ymax;
    }
}

my $j = $ymin;
my $i = $xmin;
++$j until exists $lagoon{$j}{$i};
++$j;
++$i;
fill($j, $i, \%lagoon, $ymin, $ymax, $xmin, $xmax);

my $count = 0;
for my $j ($ymin .. $ymax) {
    for my $i ($xmin .. $xmax) {
        ++$count if $lagoon{$j}{$i};
    }
}
say $count;

__DATA__
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
