#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };

my @seeds = split ' ', (split /: /, <>)[1];
my %map = map +($_, $_), @seeds;
while (<>) {
    chomp;
    next if "" eq $_;

    if (/:$/) {
        %map = map +($_, $_),  values %map;

    } else {
        my ($dest_start, $src_start, $length) = split ' ';
        for my $seed (keys %map) {
            next if $seed < $src_start || $seed > $src_start + $length;

            $map{$seed} = $seed - $src_start + $dest_start;
        }
    }
}

say min(values %map);

__DATA__
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
