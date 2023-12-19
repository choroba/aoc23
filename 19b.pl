#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ product };

use enum qw( VAR CMP VALUE LABEL );
use enum qw( X M A S WORKFLOW );
use enum qw( FROM TO );

my %VARS = (x => 0,
            m => 1,
            a => 2,
            s => 3);

my %ACC = (A => 1, R => 0);

my %rules;

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

my @agenda = ([map([1, 4000], X, M, A, S), 'in']);
my @accepted;
while (@agenda) {
    my $step = shift @agenda;
    my $workflow = $step->[WORKFLOW];
    if (exists $ACC{$workflow}) {
        push @accepted, [@$step[X, M, A, S]] if $ACC{$workflow};
        next
    }

    for my $rule (@{ $rules{$workflow} }) {
        my ($var, $cmp, $value, $label) = @$rule;
        if ("" eq $var) {
            push @agenda, [@$step[X, M, A, S], $label];
            last  # Empty rule is always last.
        }

        my ($from, $to) = @{ $step->[ $VARS{$var} ] };
        if ('<' eq $cmp && $from < $value) {
            if ($value < $to) {
                my @next_step = map [@$_], @$step[X, M, A, S];
                push @next_step, $label;
                $next_step[ $VARS{$var} ][TO] = $value - 1;
                push @agenda, \@next_step;

                # This is the "else" branch.
                $step->[ $VARS{$var} ][FROM] = $value;
            }

        } elsif ('>' eq $cmp && $value < $to) {
            if ($value > $from) {
                my @next_step = map [@$_], @$step[X, M, A, S];
                push @next_step, $label;
                $next_step[ $VARS{$var} ][FROM] = $value + 1;
                push @agenda, \@next_step;

                # This is the "else" branch.
                $step->[ $VARS{$var} ][TO] = $value;
            }
        }
    }
}

my $combinations = 0;
for my $acc (@accepted) {
    $combinations += product(map $_->[TO] - $_->[FROM] + 1, @$acc);
}
say $combinations;

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
