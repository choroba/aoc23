#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

use enum qw( VAR CMP VALUE LABEL );

my %VARS = (x => 0,
            m => 1,
            a => 2,
            s => 3);

my %ACC = (A => 1, R => 0);

my %rules;

sub process($workflow, $x, $m, $aa, $s) {
    for my $rule (@{ $rules{$workflow} }) {
        my $label = $rule->[LABEL];
        my $var   = $rule->[VAR];
        if ("" eq $var) {
            return $ACC{$label} if exists $ACC{$label};

            return process($label, $x, $m, $aa, $s)
        }

        my ($v) = ($x, $m, $aa, $s)[ $VARS{$var} ];
        if (   $rule->[CMP] eq '>' && $v > $rule->[VALUE]
            || $rule->[CMP] eq '<' && $v < $rule->[VALUE]
        ) {
            return $ACC{$label} if exists $ACC{$label};

            return process($label, $x, $m, $aa, $s)
        }
    }
    die "Don't know what to do next"
}


while (<>) {
    chomp;
    last unless length;

    my ($workflow, $condition_string) = /^(\w+)\{(.*)\}/
        or die "Cannot parse workflow line $.";

    while ($condition_string =~ /([xmas])([<>])(\d+):(\w+)/g) {
        push @{ $rules{$workflow} }, [$1, $2, $3, $4];
    }

    if ($condition_string =~ /(\w+)$/) {
        push @{ $rules{$workflow} }, ["", "", "", $1];
    }
}

my $count = 0;
while (<>) {
    my ($x, $m, $aa, $s) = /^\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}$/
        or die "Cannot parse parts line $.";
    $count += $x + $m + $aa + $s if process(in => $x, $m, $aa, $s);
}

say $count;

__DATA__
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
