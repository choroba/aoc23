#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw{ signatures };

use ARGV::OrDATA;

sub adjacent($y, $x, $schematic) {
    my @adj_y = grep $_ >= 0 && $_ <= $#{ $schematic }, $y - 1 .. $y + 1;
    my @adj_x = grep $_ >= 0 && $_ <= $#{ $schematic->[$y] }, $x - 1 .. $x + 1;

    my $count = 0;
    for my $j (@adj_y) {
        my $line = join "", @{ $schematic->[$j] }[@adj_x];
        $count += ($line !~ /[0-9]/)            ? 0
                : ($line =~ /[0-9][^0-9][0-9]/) ? 2
                :                                 1;
    }
    return 0 unless 2 == $count;

    my @numbers;
    for my $j (@adj_y) {
        my $i = 0;
        while ($i <= $#adj_x) {
            if ($schematic->[$j][ $adj_x[$i] ] =~ /[0-9]/) {
                my $from = $adj_x[$i];
                --$from while $from >= 0  && $schematic->[$j][$from] =~ /[0-9]/;
                ++$from;

                my $to = $adj_x[$i] + 1;
                ++$to while $to <= $#{ $schematic->[$j] }
                            && $schematic->[$j][$to] =~ /[0-9]/;
                --$to;

                push @numbers, join "", @{ $schematic->[$j] }[$from .. $to];
                $i++ while $i <= $#adj_x && $adj_x[$i] <= $to;
            } else {
                ++$i;
            }
        }
    }
    return $numbers[0] * $numbers[1]
}

my $sum = 0;
my @schematic = map { chomp; [split //] } <>;
for my $y (0 .. $#schematic) {
    for my $x (0 .. $#{ $schematic[$y] }) {
        $sum += adjacent($y, $x, \@schematic) if '*' eq $schematic[$y][$x];
    }
}

say $sum;

__DATA__
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
