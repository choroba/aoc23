#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

use Memoize qw{ memoize };

sub count($left, $right) {
    my @g = split /,/, $right;
    my $current_group_length = 0;
    my $pos = 0;
    while ($pos < length $left) {
        my $char = substr $left, $pos, 1;

        if ('#' eq $char) {
            ++$current_group_length;
            my @h = ("", @g);
            return 0 if ! @g || $current_group_length > $g[0];

        } elsif ('?' eq $char) {
            last

        } elsif ($current_group_length) {
            if ($g[0] == $current_group_length) {
                $current_group_length = 0;
                $left = substr $left, $pos;
                $pos = 0;
                shift @g;

            } else {
                return 0
            }
        }
    } continue {
        ++$pos
    }

    shift @g if @g
             && $pos == length $left
             && $left =~ /#$/
             && $current_group_length == $g[0];

    return 1 if ! @g && $pos == length $left;;

    if ($pos < length $left) {
        my $one = $left =~ s/\?/./r;
        my $two = $left =~ s/\?/#/r;
        $one = substr $one, $pos if 0 == $current_group_length
                                 && '.' eq substr $one, $pos + 1, 1;
        $two = substr $two, $pos if 0 == $current_group_length
                                 && '.' eq substr $two, $pos + 1, 1;
        $one =~ s/\.+/./g;
        $one =~ s/^\.//;
        my $g = join ',', @g;
        return count($one, $g) + count($two, $g)
    }
}
memoize('count');

my $count = 0;
while (<>) {
    print {*STDERR} "$. \r";
    my ($left, $right) = split;
    $left = join '?', ($left) x 5;
    $right = join ',', ($right) x 5;
    $left =~ s/\.+/./g;
    $left =~ s/^\.//;
    $count += count($left, $right);
}

say $count;

__DATA__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
