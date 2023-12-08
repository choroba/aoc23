#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use Math::Prime::Util qw{ lcm };

chomp( my $instructions = <> );

<>;
my %map;
my @where;
while (<>) {
    my ($from, $left, $right) = /(\w+) = \((\w+), (\w+)\)/;
    $map{$from} = [$left, $right];
    push @where, $from if $from =~ /A$/;
}
my $i = 1;
my $reached = '0' x 3;
my %visited;
my @cycle;
while (1) {
    @where = map $map{$_}[
        substr($instructions, ($i - 1) % length $instructions, 1) eq 'R'
    ], @where;

    for (0 .. $#where) {
        $cycle[$_] //= [$i, $i - $visited{$_}{ $where[$_] }]
            if $visited{$_}{ $where[$_] };
        $visited{$_}{ $where[$_] } = $i if $where[$_] =~ /Z$/;
    }
    last if @where == grep $_, @cycle;
    ++$i;
}

say lcm(map $_->[1], @cycle);

__DATA__
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
