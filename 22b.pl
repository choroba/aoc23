#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

use enum qw( X Y Z );

sub cubes($brick) {
    my @cubes;
    my ($x0, $y0, $z0, $x1, $y1, $z1) = @$brick;
    my @direction = ($x0 <=> $x1, $y0 <=> $y1, $z0 <=> $z1);
    my ($x, $y, $z) = ($x0, $y0, $z0);
    while (1) {
        push @cubes, [$x, $y, $z];
        last if $x == $x1 && $y == $y1 && $z == $z1;

        $x -= $direction[X];
        $y -= $direction[Y];
        $z -= $direction[Z];
    }
    return @cubes
}

my @bricks;
while (<>) {
    chomp;
    push @bricks, [split /[,~]/];
}

my %space;
for my $brick_index (0 .. $#bricks) {
    my $brick = $bricks[$brick_index];
    for my $cube (cubes($brick)) {
        my ($x, $y, $z) = @$cube;
        $space{$x}{$y}{$z} = $brick_index;
    }
}

while (1) {
    my $was_changed;
    for my $brick_index (0 .. $#bricks) {
        my $brick = $bricks[$brick_index];
        my $can_fall = 1;
        my @cubes = cubes($brick);

        my @bellow = grep defined,
                     map $space{ $_->[X] }{ $_->[Y] }{ $_->[Z] - 1 },
                     @cubes;

        undef $can_fall if grep $_ >= 0 && $_ != $brick_index, @bellow;
        grep 1 == $_->[Z], @cubes and undef $can_fall for @cubes;
        next unless $can_fall;

        $was_changed = 1;
        delete $space{ $_->[X] }{ $_->[Y] }{ $_->[Z] } for @cubes;
        $space{ $_->[X] }{ $_->[Y] }{ $_->[Z] - 1 } = $brick_index
            for @cubes;
        --$_ for $brick->[2], $brick->[5];
    }

    last unless $was_changed;
}

my (%supports, %supported_by);
for my $brick_index (0 .. $#bricks) {
    my $brick = $bricks[$brick_index];
    for my $cube (cubes($brick)) {
        if ($cube->[Z] > 1
            && exists $space{ $cube->[X] }{ $cube->[Y] }{ $cube->[Z] - 1 }
            && $space{ $cube->[X] }{ $cube->[Y] }{ $cube->[Z] - 1}
                != $brick_index
        ) {
            my $b1 = $space{ $cube->[X] } { $cube->[Y] } { $cube->[Z] - 1 };
            undef $supports{$b1}{$brick_index};
            undef $supported_by{$brick_index}{$b1};

        }
    }
}

my $fall_tally = 0;
for my $brick_index (0 .. $#bricks) {
    my %fall = ($brick_index => undef);
    my @agenda = map [$_, $brick_index], keys %{ $supports{$brick_index} };
    while (@agenda) {
        my ($supported, $supported_by) = @{ shift @agenda };
        my @other_support = grep $_ != $supported_by,
                            grep ! exists $fall{$_},
                            keys %{ $supported_by{$supported} };
        if (! @other_support) {
            push @agenda, map [$_, $supported],
                          grep ! exists $fall{$_},
                          keys %{ $supports{$supported} };
            undef $fall{$supported};
        }
    }
    $fall_tally += -1 + keys %fall;
}

say $fall_tally;

__DATA__
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
