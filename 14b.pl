#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

sub north($dish) {
    for my $y (0 .. $#$dish) {
        for my $x (0 .. $#{ $dish->[0] }) {
            if ('O' eq $dish->[$y][$x]) {
                my $yy = $y - 1;
                while ($yy >= 0  && $dish->[$yy][$x] eq '.') {
                    $dish->[$yy][$x] = 'O';
                    $dish->[ $yy-- + 1 ][$x] = '.';
                }
            }
        }
    }
}

sub west($dish) {
    for my $x (0 .. $#{ $dish->[0] }) {
        for my $y (0 .. $#$dish) {
            if ('O' eq $dish->[$y][$x]) {
                my $xx = $x - 1;
                while ($xx >= 0  && $dish->[$y][$xx] eq '.') {
                    $dish->[$y][$xx] = 'O';
                    $dish->[ $y][ $xx-- + 1 ] = '.';
                }
            }
        }
    }
}

sub south($dish) {
    for my $y (reverse 0 .. $#$dish) {
        for my $x (0 .. $#{ $dish->[0] }) {
            if ('O' eq $dish->[$y][$x]) {
                my $yy = $y + 1;
                while ($yy <= $#$dish  && $dish->[$yy][$x] eq '.') {
                    $dish->[$yy][$x] = 'O';
                    $dish->[ $yy++ - 1 ][$x] = '.';
                }
            }
        }
    }
}

sub east($dish) {
    for my $x (reverse 0 .. $#{ $dish->[0] }) {
        for my $y (0 .. $#$dish) {
            if ('O' eq $dish->[$y][$x]) {
                my $xx = $x + 1;
                while ($xx <= $#{ $dish->[0] }  && $dish->[$y][$xx] eq '.') {
                    $dish->[$y][$xx] = 'O';
                    $dish->[ $y][ $xx++ - 1 ] = '.';
                }
            }
        }
    }
}

sub count($dish) {
    my $load = 0;
    for my $y (0 .. $#$dish) {
        $load += (@$dish - $y) * grep 'O' eq $_, @{ $dish->[$y] };
    }
    return $load
}

sub cycle($dish) {
    north($dish);
    west($dish);
    south($dish);
    east($dish);
    return count($dish)
}

my @dish;
while (my $line = <>) {
    chomp $line;
    push @dish, [split //, $line];
}

my %repeat;
my @values;
my $previous = -2;
my $s;
my $LAST = 300;  # Might be higher for some inputs.
for my $c (0 .. $LAST) {
    my $v = cycle(\@dish);
    push @values, $v;
    push @{ $repeat{$v} }, $c;
}

my ($start, $length);
LENGTH:
for my $l (2 .. 100) {
    my $s = $LAST - $l * 2;
    for my $i ( $s .. $LAST) {
        my $at = $s + (($i - $s) % $l);
        next LENGTH unless $values[$i] == $values[$at];
    }
    $start  = $s;
    $length = $l;
    last LENGTH
}

# Check.
for my $i ($start / 2 .. $LAST) {
    my $at = $start + (($i - $start) % $length);
    die "$at \@ $i: $values[$i] != $values[$at]"
        unless $values[$i] == $values[$at];
}

my $i = 1000000000 - 1;
my $at = $start + (($i - $start) % $length);
say $values[$at];

__DATA__
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
