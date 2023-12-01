#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $sum = 0;
while (<>) {
    s/^\D+//;
    s/\D+$//;
    my ($left) = /^(.)/;
    my ($right) = /(.)$/;
    $sum += "$left$right";
}
say $sum;

__DATA__
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
