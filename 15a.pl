#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @seq = do { local $/ = ','; <> };

my $sum = 0;
for my $elem (@seq) {
    my $value = 0;
    for my $char (split //, $elem) {
        next if $char eq "\n" || $char eq ',';

        $value += ord $char;
        $value *= 17;
        $value %= 256;
    }
    $sum += $value;
}
say $sum;

__DATA__
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
