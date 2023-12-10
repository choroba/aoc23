#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %PIPE = ('|' => [[-1, 0], [ 1, 0]],
            '-' => [[0, -1], [ 0, 1]],
            'L' => [[-1, 0], [ 0, 1]],
            'J' => [[-1, 0], [0, -1]],
            '7' => [[0, -1], [ 1, 0]],
            'F' => [[0,  1], [ 1, 0]],
            '.' => []);

# down left, down right, right up, right down
my %CHANGE = ('|' => [ 1,  1, -1, -1],
              '-' => [-1, -1,  1,  1],
              'L' => [ 1, -1, -1,  1],
              'J' => [-1,  1, -1,  1],
              '7' => [-1,  1,  1, -1],
              'F' => [ 1, -1,  1, -1],
              '.' => [ 1,  1,  1,  1]);

my @start;
my @field;
my @change;
while (my $line = <>) {
    chomp $line;
    push @field, [map $PIPE{$_}, split //, $line];
    push @change,[map $CHANGE{$_}, split //, $line];
    @start = ($#field, pos($line) - 1) if $line =~ /S/g;
}

my @pos;
for my $y ($start[0] - 1 .. $start[0] + 1) {
    next if $y < 0 || $y > $#field;

    for my $x ( $start[1] - 1 .. $start[1] + 1) {
        next if $x < 0 || $x > $#{ $field[0] }
             || $y == $start[0] && $x == $start[1];

        my @pipe = @{ $field[$y][$x] // [] };

        for my $coords (@pipe) {
            if (   $coords->[0] + $y == $start[0]
                   && $coords->[1] + $x == $start[1]
            ) {
                push @pos, [$y, $x];
            }
        }
    }
}

# Fill in field and change for S.
my @diff = map [$_->[0] - $start[0], $_->[1] - $start[1]], @pos;
my ($char) = grep        $PIPE{$_}[0][0] == $diff[0][0]
                      && $PIPE{$_}[0][1] == $diff[0][1]
                      && $PIPE{$_}[1][0] == $diff[1][0]
                      && $PIPE{$_}[1][1] == $diff[1][1],
             grep '.' ne $_,
             keys %PIPE;
$field[ $start[0] ][ $start[1] ] = \@diff;
$change[ $start[0] ][ $start[1] ] = $CHANGE{$char};

# Find the loop.

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
$visited{ $pos[0][0] }{ $pos[0][1] } = 1;

# Identify the inside tiles.

# .1
# 02
my @side = ([[-1, -1, $visited{0}{0} ? 1 : -1]]);
my $inside = 0;
for my $y (0 .. $#field - 1) {              # Last line is never inside.
    for my $x (0 .. $#{ $field[0] } - 1) {  # Neither is the last column.
        next if 0 == $y && 0 == $x;

        my $v = $visited{$y}{$x};
        if ($y > 0) {
            $side[$y][$x] = [
                $side[ $y - 1 ][$x][0] * ($v ? $change[$y][$x][0] : 1),
                $side[ $y - 1 ][$x][2],
                $side[ $y - 1 ][$x][2] * ($v ? $change[$y][$x][1] : 1)
            ];
        } else {
            $side[0][$x] = [
                -1,  # First line is never inside.
                $side[0][ $x - 1 ][1] * ($v ? $change[0][$x][2] : 1),
                $side[0][ $x - 1 ][2] * ($v ? $change[0][$x][3] : 1)
            ];
        }
        ++$inside if ! $v && 1 == $side[$y][$x][2];
    }
}

say $inside;

__DATA__
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
