#!/usr/bin/perl
use warnings;
use strict;

my %FORMAT = ('&' => 'shape=oval,fillcolor=cyan',
              '%' => 'shape=rectangle,fillcolor=pink');

open my $dot, '|-', dot => '-Tx11';

print {$dot} 'strict digraph {node[shape=circle,style=filled,fillcolor=red];';
while (<>) {
    print {$dot} s/([&%])(\w+)/$2\[$FORMAT{$1}];$2/gr
}

print {$dot} '}';
