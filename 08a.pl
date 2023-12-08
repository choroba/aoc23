#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

chomp( my $instructions = <> );

<>;
my %map;
while (<>) {
    my ($from, $left, $right) = /(\w+) = \((\w+), (\w+)\)/;
    $map{$from} = [$left, $right];
}

my $where = 'AAA';
my $i = 0;
while (1) {
    $where = $map{$where}[
        substr($instructions, $i % length $instructions, 1) eq 'R' ];
    last if 'ZZZ' eq $where;
    ++$i;
}
say $i + 1;

__DATA__
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
