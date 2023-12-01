#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %DIGIT = (one => 1, two   => 2, three => 3, four => 4, five => 5,
             six => 6, seven => 7, eight => 8, nine => 9);
my $DIGIT_REGEX = join '|', keys %DIGIT;

my $sum = 0;
while (<>) {
    my ($left)  = s/    ($DIGIT_REGEX)/$DIGIT{$1}/xr   =~ /(\d)/;
    my ($right) = s/(.*)($DIGIT_REGEX)/$1$DIGIT{$2}/xr =~ /.*(\d)/;
    $sum += "$left$right";
}
say $sum;

__DATA__
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
