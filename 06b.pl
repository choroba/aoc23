#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $time     = join "", <> =~ /([0-9]+)/g;
my $distance = join "", <> =~ /([0-9]+)/g;

my $hold_lower = 1;
++$hold_lower while ($time - $hold_lower) * $hold_lower <= $distance;

my $hold_upper = $time - 1;
--$hold_upper while ($time - $hold_upper) * $hold_upper <= $distance;

say 1 + $hold_upper - $hold_lower;

exit;

# Interestingly, the Part 1 way also works, but takes 6.3 seconds
# versus 0.5 of the above.

my $wins = grep $_ > $distance,
           map +($time - $_) * $_,
           1 .. $time - 1;
say $wins;

__DATA__
Time:      7  15   30
Distance:  9  40  200
