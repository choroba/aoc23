#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use utf8;
use open OUT => ':encoding(UTF-8)', ':std';

use ARGV::OrDATA;
use Term::ANSIColor qw{ colored };
use Time::HiRes qw{ usleep };

*STDOUT->autoflush(1);
print "\e[?25l";

sub clear { print "\e[2J"; cgoto(0, 0) }
sub cgoto { my @o = map 1 + $_, @_; print "\e[$o[0];$o[1]f" }

my %PIPE = ('|' => [[-1, 0], [ 1, 0]],
            '-' => [[0, -1], [ 0, 1]],
            'L' => [[-1, 0], [ 0, 1]],
            'J' => [[-1, 0], [0, -1]],
            '7' => [[0, -1], [ 1, 0]],
            'F' => [[0,  1], [ 1, 0]],
            '.' => []);

# down left, down right, right up, right down
my %CHANGE = ('|' => [ 1,  1, -1, -1],
              '-' => [-1, -1,  1,  1],
              'L' => [ 1, -1, -1,  1],
              'J' => [-1,  1, -1,  1],
              '7' => [-1,  1,  1, -1],
              'F' => [ 1, -1,  1, -1],
              '.' => [ 1,  1,  1,  1]);

my @start;
my @field;
my @change;
my @lines;
clear();
while (my $line = <>) {
    print colored($line, 'white'); usleep(2000);
    chomp $line;
    push @field, [map $PIPE{$_}, split //, $line];
    push @change,[map $CHANGE{$_}, split //, $line];
    @start = ($#field, pos($line) - 1) if $line =~ /S/g;
    $line =~ tr/-|F7LJ/─│┌┐└┘/;
    push @lines, $line;
}

cgoto(0, 0);
sleep 1;
usleep(9000), say colored($_, 'bright_white') for @lines;

my @pos;
for my $y ($start[0] - 1 .. $start[0] + 1) {
    next if $y < 0 || $y > $#field;

    for my $x ( $start[1] - 1 .. $start[1] + 1) {
        next if $x < 0 || $x > $#{ $field[0] }
             || $y == $start[0] && $x == $start[1]
             || ! ($y == $start[0] || $x == $start[1]);

        my @pipe = @{ $field[$y][$x] // [] };

        sleep 1; cgoto($y, $x);
        print colored(substr($lines[$y], $x, 1),'bright_yellow on_green');

        for my $coords (@pipe) {
            if (   $coords->[0] + $y == $start[0]
                   && $coords->[1] + $x == $start[1]
            ) {
                push @pos, [$y, $x];
            }
        }
    }
}

# Fill in field and change for S.
my @diff = map [$_->[0] - $start[0], $_->[1] - $start[1]], @pos;
my ($char) = grep        $PIPE{$_}[0][0] == $diff[0][0]
                      && $PIPE{$_}[0][1] == $diff[0][1]
                      && $PIPE{$_}[1][0] == $diff[1][0]
                      && $PIPE{$_}[1][1] == $diff[1][1],
             grep '.' ne $_,
             keys %PIPE;
$field[ $start[0] ][ $start[1] ] = \@diff;
$change[ $start[0] ][ $start[1] ] = $CHANGE{$char};
sleep 1; cgoto(@start);
print colored('S', 'red on_cyan');
sleep 1; cgoto(@start);
print colored($char =~ tr/-|F7LJ/━┃┏┓┗┛/r, 'bright_red on_cyan'); sleep 2;

# Find the loop.

my $step = 1;
my %visited;
$visited{ $start[0] }{ $start[1] } = 1;
do {{
    usleep(55_000_000/(@{ $field[0] } * @field));
    for my $pos (@pos) {
        cgoto(@$pos);
        print colored(substr($lines[$pos->[0]], $pos->[1], 1) =~ tr/-|F7LJ/━┃┏┓┗┛/r, 'bright_red');
    }

    $visited{ $_->[0] }{ $_->[1] } = 1 for @pos;
    my @next;
    for my $p (0, 1) {
        my ($y, $x) = @{ $pos[$p] };
        my @pipe = @{ $field[$y][$x] };
        for my $coord (@pipe) {
            my $j = $coord->[0] + $y;
            my $i = $coord->[1] + $x;
            push @next, [$j, $i] unless $visited{$j}{$i};
        }
    }
    @pos = @next;
    ++$step;
}} until $pos[0][0] == $pos[1][0] && $pos[0][1] == $pos[1][1];
$visited{ $pos[0][0] }{ $pos[0][1] } = 1;
sleep 1;
for my $pos (@pos) {
    cgoto(@$pos);
    print colored(substr($lines[$pos->[0]], $pos->[1], 1), 'red');
}

# Identify the inside tiles.

# .1
# 02
my @side = ([[-1, -1, $visited{0}{0} ? 1 : -1]]);
my $inside = 0;
for my $y (0 .. $#field - 1) {              # Last line is never inside.
    for my $x (0 .. $#{ $field[0] } - 1) {  # Neither is the last column.
        next if 0 == $y && 0 == $x;

        my $v = $visited{$y}{$x};
        if ($y > 0) {
            $side[$y][$x] = [
                $side[ $y - 1 ][$x][0] * ($v ? $change[$y][$x][0] : 1),
                $side[ $y - 1 ][$x][2],
                $side[ $y - 1 ][$x][2] * ($v ? $change[$y][$x][1] : 1)
            ];
        } else {
            $side[0][$x] = [
                -1,  # First line is never inside.
                $side[0][ $x - 1 ][1] * ($v ? $change[0][$x][2] : 1),
                $side[0][ $x - 1 ][2] * ($v ? $change[0][$x][3] : 1)
            ];
        }
        next if $v;

        if (1 == $side[$y][$x][2]) {
            ++$inside;
            cgoto($y, $x);
            usleep(3_000); print colored(substr($lines[$y], $x, 1), 'blue on_green');
        } else {
            cgoto($y, $x);
            usleep(1_000); print colored(substr($lines[$y], $x, 1), 'blue');

        }
    }
}

cgoto(scalar @lines, 0);
print "\e[?25h";
say colored($inside, 'bright_yellow');

__DATA__
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
