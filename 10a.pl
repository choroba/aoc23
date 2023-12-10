#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %PIPE = ('|' => [[-1, 0], [ 1, 0]],
            '-' => [[0, -1], [ 0, 1]],
            'L' => [[-1, 0], [ 0, 1]],
            'J' => [[0, -1], [-1, 0]],
            '7' => [[0, -1], [ 1, 0]],
            'F' => [[0,  1], [ 1, 0]],
            '.' => []);

my @start;
my @field;
while (my $line = <>) {
    chomp $line;
    push @field, [map $PIPE{$_}, split //, $line];
    @start = ($#field, pos($line) - 1) if $line =~ /S/g;
}

my @pos;
for my $y ($start[0] - 1 .. $start[0] + 1) {
    next if $y < 0 || $y > $#field;

    for my $x ( $start[1] - 1 .. $start[1] + 1) {
        next if $x < 0 || $y > $#{ $field[0] }
             || $y == $start[0] && $x == $start[1];

        my @pipe = @{ $field[$y][$x] };
        for my $coords (@pipe) {
            if (   $coords->[0] + $y == $start[0]
                   && $coords->[1] + $x == $start[1]
               ) {
                push @pos, [$y, $x];
            }
        }
    }
}

my $step = 1;
my %visited;
$visited{ $start[0] }{ $start[1] } = 1;
do {{
    $visited{ $_->[0] }{ $_->[1] } = 1 for @pos;
    my @next;
    for my $p (0, 1) {
        my ($y, $x) = @{ $pos[$p] };
        my @pipe = @{ $field[$y][$x] };
        for my $coord (@pipe) {
            my $j = $coord->[0] + $y;
            my $i = $coord->[1] + $x;
            push @next, [$j, $i] unless $visited{$j}{$i};
        }
    }
    @pos = @next;
    ++$step;
}} until $pos[0][0] == $pos[1][0] && $pos[0][1] == $pos[1][1];
say $step;

__DATA__
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
