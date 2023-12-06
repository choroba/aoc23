#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my (undef, @times)     = split ' ', <>;
my (undef, @distances) = split ' ', <>;

my $score = 1;
for my $race (0 .. $#times) {
    my $wins = grep $_ > $distances[$race],
               map +($times[$race] - $_) * $_,
               1 .. $times[$race] - 1;
    $score *= $wins;
}

say $score;

__DATA__
Time:      7  15   30
Distance:  9  40  200
