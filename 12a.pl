#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $count = 0;
while (<>) {
    print {*STDERR} "$. \r";
    my ($left, $right) = split;
    my $condition = $left =~ tr/?/:/r;
    while (1) {
        my $g = join ',', map length, $condition =~ /([#=]+)/g;
        ++$count if $g eq $right;

        $condition =~ /.*[:=]/g;
        my $pos = (pos $condition // 0) - 1;

        if (':' eq substr $condition, $pos, 1) {
            substr $condition, $pos, 1, '=';
        } else {
            while ('=' eq substr $condition, $pos, 1) {
                substr $condition, $pos, 1, ':';
                1 until substr($condition, --$pos, 1) =~ /[:=]/;
            }
            last if $pos < 0;

            substr $condition, $pos, 1, '=';
        }
    }
}

say $count;

__DATA__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
