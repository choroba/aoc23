#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw{ signatures };

use ARGV::OrDATA;

sub adjacent($y, $from, $to, $schematic) {
    my @adj_y = grep $_ >= 0 && $_ <= $#{ $schematic }, $y - 1, $y, $y + 1;
    my @adj_x = grep $_ >= 0 && $_ <= $#{ $schematic->[$y] },
                $from - 1 .. $to + 1;
    my $symbol = 0;
    for my $j (@adj_y) {
        for my $i (@adj_x) {
            return 1 if $schematic->[$j][$i] =~ /[^0-9.]/;
        }
    }
    return 0
}

my $sum = 0;
my @schematic = map { chomp; [split //] } <>;
for my $y (0 .. $#schematic) {
    my $x = 0;
    while ($x <= $#schematic) {
        if ($schematic[$y][$x] =~ /[0-9]/) {
            my $from = $x;
            ++$x while $x <= $#{ $schematic[$y] }
                       && $schematic[$y][$x] =~ /[0-9]/;
            if (adjacent($y, $from, $x - 1, \@schematic)) {
                my $number = join "", @{ $schematic[$y] }[$from .. $x - 1];
                $sum += $number;
            }
        } else {
            ++$x;
        }
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
