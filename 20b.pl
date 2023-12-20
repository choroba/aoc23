#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use Math::Prime::Util qw{ lcm };
use Storable qw{ dclone };

{   package Communication;
    use Moo;
    use experimental qw( signatures );

    use enum qw( LOW HIGH );
    use enum qw( MODULE PULSE );
    use namespace::clean;

    has queue         => (is => 'ro', default => sub {[]});
    has _conjunctions => (is => 'ro', default => sub {{}});
    has _modules      => (is => 'ro', default => sub {{}});

    sub add_module($self, $module) {
        $self->_modules->{ $module->name } = $module;
        undef $self->_conjunctions->{ $module->name }
            if 'Module::Conjunction' eq ref $module;
    }

    sub push_button($self) {
        push @{ $self->queue() }, [button => 'broadcaster', LOW];
    }

    sub step($self) {
        while (my $step = shift @{ $self->queue }) {
            my ($source, $target, $pulse) = @$step;
            $self->add_module('Module::Untyped'->new(name => $target))
                unless exists $self->_modules->{$target};

            $self->_modules->{$target}->receive($pulse, $source);
            push @{ $self->queue },
                 map [$target, @$_],
                 $self->_modules->{$target}->process;
        }
    }

    sub modules($self) { values %{ $self->_modules } }

    sub initialise($self) {
        for my $m ($self->modules) {
            for my $d (@{ $m->destination }) {
                $self->_modules->{$d}->add_input($m->name)
                    if exists $self->_conjunctions->{$d};
            }
        }
    }

    sub serialise($self) {
        return join "",
                    map $self->_modules->{$_}->serialise,
                    sort keys %{ $self->_modules }
    }
}

{   package Module;
    use Moo;
    use experimental qw( signatures );

    has name        => (is => 'ro', required => 1);
    has destination => (is => 'ro', default => sub {[]});
    has _out        => (is => 'ro', default  => sub {[]});

    sub emit($self, $pulse) {
        push @{ $self->_out }, [$_, $pulse] for @{ $self->destination };
    }

    sub process($self) {
        splice @{ $self->_out }
    }

    sub serialise { "" }
}

{   package Module::Broadcast;
    use Moo;
    extends 'Module';
    use experimental qw( signatures );

    sub receive($self, $pulse, $source) {
        $self->emit($pulse);
    }
}

{   package Module::FlipFlop;
    use Moo;
    extends 'Module';
    use experimental qw( signatures );

    use enum qw( LOW HIGH );
    use namespace::clean;

    has state => (is => 'rw', default => 0);

    sub flip($self) {
        $self->state(! $self->state);
    }

    sub receive($self, $pulse, $source) {
        if (LOW == $pulse) {
            $self->flip;
            $self->emit($self->state ? HIGH : LOW);
        }
    }

    sub serialise($self) { $self->state ? 1 : 0 }
}

{   package Module::Conjunction;
    use Moo;
    extends 'Module';
    use experimental qw( signatures );

    use enum qw( LOW HIGH );
    use namespace::clean;

    has memory => (is => 'ro', default => sub {{}});
    has inputs => (is => 'rw', default => sub {[]});

    sub add_input($self, $name) {
        push @{ $self->inputs }, $name;
        $self->memory->{$name} = LOW;
    }

    sub receive($self, $pulse, $source) {
        $self->memory->{$source} = $pulse;
        my $all_high = ! grep LOW == $self->memory->{$_}, @{ $self->inputs };
        $self->emit($all_high ? LOW : HIGH);
    }

    sub serialise($self) {
        return unpack 'H*',
               pack 'B*',
               @{ $self->memory }{ sort @{ $self->inputs } }
    }
}

{   package Module::Untyped;
    use Moo;
    extends 'Module';
    sub receive {}
}

sub duplicities(@members) {
    my %seen;
    $seen{$_}++ and return 1 for @members;
    return 0
}

my %TYPEMAP = (broadcaster => 'Broadcast',
               '%'         => 'FlipFlop',
               '&'         => 'Conjunction');
my $TYPE_RE = join '|', map quotemeta, keys %TYPEMAP;

my $c0 = 'Communication'->new;
while (<>) {
    chomp;
    my ($name, $destination) = split / -> /;
    my ($type) = $name =~ /($TYPE_RE)/;
    my $class = 'Module::' . $TYPEMAP{$type};
    $name =~ s/^[%&]//;
    $c0->add_module($class->new(name        => $name,
                                destination => [split /, /, $destination]));
}

$c0->initialise;

my @final = ('rx');
while (1) {
    my @next = grep duplicities(@final, @{ $_->destination }),
               $c0->modules;
    last if grep 'Module::Conjunction' ne ref $_, @next;
    @final = map $_->name, @next;
}

my %start;
for my $f (@final) {
    my @start = ($f);
    while (1) {
        my @next = grep duplicities(@start, @{ $_->destination }),
                   $c0->modules;
        last if grep $_->name eq 'broadcaster', @next;
        @start = map $_->name, @next;
    }
    $start{$f} = (grep
                      duplicities($_,
                                  @{ $c0->_modules->{broadcaster}->destination }
                      ),
                  @start)[0];
}

my @steps;
for my $f (@final) {
    my $c1 = dclone($c0);
    @{ $c1->_modules->{broadcaster}->destination } = ($start{$f});
    my $steps = 0;
    my %state;
    until ($state{ $c1->serialise }++) {
        $c1->push_button;
        ++$steps;
        $c1->step;
    }
    push @steps, $steps - 1;
}

say lcm(@steps);

__DATA__
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
