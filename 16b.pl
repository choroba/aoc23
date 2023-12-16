#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use List::Util qw{ max };
use Storable qw{ dclone };

my %STEP = (
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
);

sub solve($beams, $contraption) {
    my %visited;
    while (@$beams) {
        my @new;
        for my $beam (@$beams) {
            my ($y, $x, $dy, $dx) = @$beam;
            $contraption->[$y][$x][1] = 1;
            undef $visited{$y}{$x}{$dy}{$dx};
            my @next = @{ $STEP{"$dy$dx$contraption->[$y][$x][0]"}
                          // [[$dy, $dx]] };
            for my $n (@next) {
                my ($ny, $nx) = ($y + $n->[0], $x + $n->[1]);
                next if $ny < 0 || $ny > $#$contraption
                     || $nx < 0 || $nx > $#{ $contraption->[0] }
                     || exists $visited{$ny}{$nx}{ $n->[0] }{ $n->[1] };
                push @new, [$ny, $nx, @$n];
            }
        }
        @$beams = @new;
    }
    my $energized = grep $_->[1], map @$_, @$contraption;
    return $energized
}

my @contraption;
while (<>) {
    chomp;
    push @contraption, [map [$_, 0], split //];
}

my @e;
for my $X (0 .. $#{ $contraption[0] }) {
    print {*STDERR} "x$X  \r";
    push @e, solve([[0, $X, 1, 0]], dclone(\@contraption)),
             solve([[$#contraption, $X, -1, 0]], dclone(\@contraption));
}
for my $Y (0 .. $#contraption) {
    print {*STDERR} "y$Y  \r";
    push @e, solve([[$Y, 0, 0, 1]], dclone(\@contraption)),
             solve([[$Y, $#{ $contraption[0] }, 0, -1]], dclone(\@contraption));
}

say max(@e), ' ';

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
