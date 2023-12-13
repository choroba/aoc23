#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

sub search($stripe, $found) {
    for my $i (1 .. length($stripe) - 1) {
        my $part = substr $stripe, $i;
        my $reversed = reverse substr $stripe, 0, $i;
        ++$found->{$i} if (length($part) < length($reversed)
                           && 0 == index $reversed, $part)
                       || 0 == index $part, $reversed;
    }
}

my $summary = 0;
my @lines;
my %vertical;
my $done;
while (defined( my $line = <> ) || ! $done) {
    $line //= "";
    chomp $line;
    if (length $line) {
        push @lines, $line;
        search($line, \%vertical);

    } else {
        my @v_mirrors = grep $vertical{$_} == @lines, keys %vertical;
        $summary += $v_mirrors[0] if 1 == @v_mirrors;

        my @columns;
        for my $line (@lines) {
            my $i = 0;
            $columns[$i++] .= $_ for split //, $line;
        }

        my %horizontal;
        search($_, \%horizontal) for @columns;
        my @h_mirrors = grep $horizontal{$_} == @columns, keys %horizontal;
        $summary += 100 * $h_mirrors[0] if 1 == @h_mirrors;

        last if eof;

        %vertical = ();
        @lines = ();
    }
}
say $summary;

__DATA__
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
