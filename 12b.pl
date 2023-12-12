#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

use threads;
use threads::shared;
use Thread::Queue;

my  %cache;
sub count($left, @g) {
    return $cache{$left}{"@g"} if exists $cache{$left}
                               && exists $cache{$left}{"@g"};

    my $current_group_length = 0;
    my $pos = -1;
    while (++$pos < length $left) {
        my $char = substr $left, $pos, 1;

        if ('#' eq $char) {
             return 0 if ! @g || ++$current_group_length > $g[0];

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
    }

    if ($pos == length $left && (! @g || $current_group_length == $g[0])) {
        shift @g;
        return 1 unless @g;
    }

    if ($pos < length $left) {
        my $one = $left;
        substr $one, $pos, 1, '.';
        my $two = $left;
        substr $two, $pos, 1, '#';
        $one = substr $one, $pos if 0 == $current_group_length
                                 && '.' eq substr $one, $pos + 1, 1;
        $two = substr $two, $pos if 0 == $current_group_length
                                 && '.' eq substr $two, $pos + 1, 1;
        $one =~ s/\.\././;
        my $g = join ',', @g;
        return $cache{$left}{"@g"} = count($one, @g) + count($two, @g)
    }
}

my $qin  = 'Thread::Queue'->new;
my $qout = 'Thread::Queue'->new;

my @workers = map 'threads'->create(
    sub {
        while (defined( my $in = $qin->dequeue )) {
            my ($left, @g) = @$in;
            $qout->enqueue(count($left, @g));
        }
    }
), 1 .. 8;
$_->detach for @workers;

while (<>) {
    print {*STDERR} "$. \r";
    my ($left, $right) = split;
    $left = join '?', ($left) x 5;
    $right = join ',', ($right) x 5;
    $left =~ s/\.+/./g;
    $left =~ s/^\.//;
    $left =~ s/\.$//;
    $qin->enqueue([$left, split /,/, $right]);
}

$qin->end;

my $count = 0;
for (1 .. $.) {
    my $r = $qout->dequeue;
    $count += $r;
}

say $count;

__DATA__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
