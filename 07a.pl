#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

use enum qw[ TYPE STRENGTH BID ];

my %STRENGTH;
$STRENGTH{$_} = chr(97 + keys %STRENGTH) for qw( 2 3 4 5 6 7 8 9 T J Q K A );

my %TYPE = ( 11111 => 1,
             1112  => 2,
             122   => 3,
             113   => 4,
             23    => 5,
             14    => 6,
             5     => 7);

my @hands;
while (<>) {
    my ($cards, $bid) = split;
    my %count;
    ++$count{$_} for split //, $cards;
    my $type = join "", sort values %count;
    push @hands, [$TYPE{$type},
                  join("", map $STRENGTH{$_}, split //, $cards),
                  $bid];
}
@hands = sort { $a->[TYPE] <=> $b->[TYPE]
                || $a->[STRENGTH] cmp $b->[STRENGTH] } @hands;

my $winnings = 0;
for my $i (0 .. $#hands) {
    $winnings += $hands[$i][BID] * ($i + 1);
}
say $winnings;

__DATA__
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
