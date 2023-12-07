#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

use enum qw[ TYPE STRENGTH BID ];

my @LABELS = qw( J 2 3 4 5 6 7 8 9 T Q K A );

my %STRENGTH;
$STRENGTH{$_} = chr(97 + keys %STRENGTH) for @LABELS;

my %TYPE = ( 11111 => 1,
             1112  => 2,
             122   => 3,
             113   => 4,
             23    => 5,
             14    => 6,
             5     => 7);

sub by_type_and_card {
    $a->[TYPE] <=> $b->[TYPE]
    || $a->[STRENGTH] cmp $b->[STRENGTH]
}

sub type($cards) {
    my %count;
    ++$count{$_} for split //, $cards;
    return join "", sort values %count
}

sub apply_joker($cards, @use) {
    my @pretend = map $cards =~ s/J/$_/r, @use;
    @pretend = map apply_joker($_, @use), @pretend if $pretend[0] =~ /J/;
    return @pretend
}

my @hands;
while (<>) {
    my ($cards, $bid) = split;

    if ($cards =~ /J/) {
        my %count = (A => 0);
        ++$count{$_} for split //, $cards;
        delete $count{J};
        my @pretend = sort by_type_and_card
                      map [$TYPE{ type($_) },
                           join("", map $STRENGTH{$_}, split //, $cards),
                           $bid],
                      apply_joker($cards, keys %count);
        push @hands, $pretend[-1];

    } else {
        my $type = type($cards);
        push @hands, [$TYPE{$type},
                      join("", map $STRENGTH{$_}, split //, $cards),
                      $bid];
    }
}
@hands = sort by_type_and_card @hands;

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
