#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use Storable qw{ dclone };

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

my %cache;
sub cycle($dish) {
    my $k = join "", map @$_, @$dish;
    if (exists $cache{$k}) {
        @$dish = @{ $cache{$k}[2] };
        return @{ $cache{$k} }[0, 1]
    }

    north($dish);
    west($dish);
    south($dish);
    east($dish);

    my $c = count($dish);
    my $key_out = join "", map @$_, @$dish;
    $cache{$k} = [$c, $key_out, dclone($dish)];
    return $c, $key_out
}

my @dish;
while (my $line = <>) {
    chomp $line;
    push @dish, [split //, $line];
}

my %repeat;
my @values = (-1);  # Disregard the initial load.
my $last = 0;
while (1) {
    my ($v, $key) = cycle(\@dish);
    push @values, $v;
    last if $repeat{$key}++ > 2;

    ++$last;
}

my ($start, $length);
LENGTH:
for my $l (2 .. $#values) {
    my $s = $last - $l * 2;
    for my $i ( $s .. $#values) {
        my $at = $s + (($i - $s) % $l);
        next LENGTH unless $values[$i] == $values[$at];
    }
    $start  = $s - $l + 1;
    $length = $l;
    last LENGTH
}

# # Check.
# say "Start: $start. Length: $length";
# say "Check: ", $start, " .. $last";
# for my $i ($start .. $last) {
#     my $at = $start + (($i - $start) % $length);
#     die "$at \@ $i: $values[$i] != $values[$at]"
#         unless $values[$i] == $values[$at];
# }

my $i = 1000000000;
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
