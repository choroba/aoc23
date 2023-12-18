#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %DIRECTION = (R => [ 0,  1],
                 L => [ 0, -1],
                 U => [-1,  0],
                 D => [ 1,  0]);
my @DIRECTION = qw( R D L U );

# Correction of previous step y, x; extra step y, x
my %TURN = (RU => [ 0,  0,  0,  1,  0,  0, -1,  0],
            RD => [ 0,  1,  0,  0,  1,  0,  0,  0],
            LU => [ 0, -1,  0,  0, -1,  0,  0,  0],
            LD => [ 0,  0,  0, -1,  0,  0,  1,  0],
            UL => [ 0,  0, -1,  0,  0,  0,  0, -1],
            UR => [-1,  0,  0,  0,  0,  1,  0,  0],
            DL => [ 1,  0,  0,  0,  0, -1,  0,  0],
            DR => [ 0,  0,  1,  0,  0,  0,  0,  1]);

my @instructions;
while (<>) {
    my ($direction, $distance) = split ' ';
    push @instructions, [$distance, $direction];
}

my $prev_dir = $instructions[-1][1];
my @vertices = ([0, 0, 0, 0]);
for my $instruction (@instructions) {
    my ($distance, $direction) = @$instruction;

    my $turn = $TURN{ $prev_dir . $direction };
    my $prev = $vertices[-1];
    $prev->[$_] += $turn->[$_] for 0 .. 3;

    push @vertices, [
        map $prev->[$_]
            + $DIRECTION{$direction}[ $_ % 2 ] * ($distance - 1)
            + $turn->[ $_ + 4 ],
        0 .. 3];
    $prev_dir = $direction;
}
$vertices[-1] = $vertices[0];

my @dig;
for my $i (0 .. $#vertices - 1) {
    $dig[0] += $vertices[ $i + 1 ][1] * $vertices[$i][0]
             - $vertices[ $i + 1 ][0] * $vertices[$i][1];
    $dig[1] += $vertices[ $i + 1 ][3] * $vertices[$i][2]
             - $vertices[ $i + 1 ][2] * $vertices[$i][3];
}

say +(sort { $b <=> $a } map abs($_) / 2, @dig)[0];

__DATA__
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
