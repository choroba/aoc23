#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @contraption;
while (<>) {
    chomp;
    push @contraption, [map [$_, 0], split //];
}

# Y, X, DY, DX
my @beams = ([0, 0, 0, 1]);
my %visited;
while (@beams) {
    my @new;
    for my $beam (@beams) {
        my ($y, $x, $dy, $dx) = @$beam;
        $contraption[$y][$x][1] = 1;
        undef $visited{$y}{$x}{$dy}{$dx};
        my @next = @{ {
            '01|'   => [[1, 0], [-1, 0]],
            '0-1|'  => [[1, 0], [-1, 0]],
            '10-'   => [[0, 1], [0, -1]],
            '-10-'  => [[0, 1], [0, -1]],
            '01/'   => [[-1, 0]],
            '0-1/'  => [[ 1, 0]],
            '10/'   => [[ 0, -1]],
            '-10/'  => [[ 0, 1]],
            '01\\'  => [[ 1, 0]],
            '0-1\\' => [[-1, 0]],
            '10\\'  => [[ 0, 1]],
            '-10\\' => [[ 0, -1]]
        }->{ "$dy$dx$contraption[$y][$x][0]" } // [[$dy, $dx]] };
        for my $n (@next) {
            my ($ny, $nx) = ($y + $n->[0], $x + $n->[1]);
            next if $ny < 0 || $ny > $#contraption
                 || $nx < 0 || $nx > $#{ $contraption[0] }
                 || exists $visited{$ny}{$nx}{ $n->[0] }{ $n->[1] };
            push @new, [$ny, $nx, @$n];
        }
    }
    @beams = @new;
}

my $energized = grep $_->[1], map @$_, @contraption;
say $energized;

__DATA__
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
