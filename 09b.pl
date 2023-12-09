#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $sum = 0;
while (<>) {
    my @history;
    $history[0] = [split];
    while (grep $_, @{ $history[-1] }) {
        push @history, [map $history[-1][$_] - $history[-1][ $_ - 1 ],
                        1 .. $#{ $history[-1] }];
    }
    unshift @{ $history[-1] }, 0;
    for my $i (reverse 0 .. $#history - 1) {
        unshift @{ $history[$i] }, $history[$i][0] - $history[ $i + 1 ][0];
    }
    $sum += $history[0][0];
}
say $sum;

__DATA__
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
