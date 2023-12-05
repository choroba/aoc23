#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };

my @seeds = split ' ', (split /: /, <>)[1];
my %map;
@{ $map{seed} }{@seeds} = (@seeds);
my @type;
while (<>) {
    chomp;
    next if "" eq $_;

    if (/^(\w+)-to-(\w+) map:$/) {
        @type = ($1, $2);
        @{ $map{ $type[1] } }{ values %{ $map{ $type[0] } } }
            = values %{ $map{ $type[0] } };

    } else {
        my ($dest_start, $src_start, $length) = split ' ';
        for my $seed (keys %{ $map{ $type[1] } }) {
            next if $seed < $src_start || $seed > $src_start + $length;

            $map{ $type[1] }{$seed} = $seed - $src_start + $dest_start;
        }
    }
}

say min(values %{ $map{ $type[1] } });

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
