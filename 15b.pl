#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @seq = do { local $/ = ','; <> };

my @boxes;
for my $elem (@seq) {
    my $value = 0;
    my ($box, $op, $fl) = $elem =~ /(.*)([-=])([0-9]*)/;
    for my $char (split //, $box) {
        next if $char eq "\n" || $char eq ',';
        last if $char eq '-'  || $char eq '=';

        $value += ord $char;
        $value *= 17;
        $value %= 256;
    }

    my $action = {
        '-' => sub {
            $boxes[$value] = [grep $_->[0] ne $box, @{ $boxes[$value] }];
        },
        '=' => sub {
            my $replaced;
            $boxes[$value] = [map { $_->[0] eq $box
                                    ? do{ $replaced = 1; [$box, $fl] }
                                    : $_
                              } @{ $boxes[$value] }];
            push @{ $boxes[$value] }, [$box, $fl] unless $replaced;
        },
    }->{$op};
    $action->();
}

my $total_power = 0;
for my $box_index (0 .. @boxes) {
    for my $lens_index (0 .. $#{ $boxes[$box_index] }) {
        my $focusing_power = ($box_index + 1)
                           * ($lens_index + 1)
                           * $boxes[$box_index][$lens_index][1];
        $total_power += $focusing_power;
    }
}

say $total_power;

__DATA__
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
