#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };

my @in = split ' ', (split /: /, <>)[1];
my @map;
while (@in) {
    my $from  = shift @in;
    my $range = shift @in;
    push @map, [$from, $from + $range - 1, 0];
}

my @type;
while (<>) {
    chomp;
    next if "" eq $_;

    if (-1 != rindex $_, ':') {
        $_ = [$_->[0] + $_->[2], $_->[1] + $_->[2], 0] for @map;

    } else {
        my ($dest_start, $src_start, $length) = split ' ';
        my @rest;
        for my $e (@map) {
            my ($from, $to, $shift) = @$e;

            my ($i0, $i1) = ($src_start, $src_start + $length - 1);
            next if $i1 < $from || $i0 > $to;

            if ($i0 < $from) {
                $i0 = $from;
            } elsif ($i0 > $from) {
                push @rest, [$from, $i0 - 1, $shift];
            }

            if ($i1 > $to) {
                $i1 = $to;
            } elsif ($i1 < $to) {
                push @rest, [$i1 + 1, $to, $shift];
            }

            $e = [$i0, $i1, $dest_start - $src_start];
        }
        push @map, @rest;
    }
}

say min(map $_->[0] + $_->[2], @map);

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
