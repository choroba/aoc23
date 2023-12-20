#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use enum qw( LOW HIGH );


{   package Communication;
    use Moo;
    use experimental qw( signatures );

    use enum qw( LOW HIGH );
    use enum qw( MODULE PULSE );
    use namespace::clean;

    has queue         => (is => 'ro', default => sub {[]});
    has sent          => (is => 'ro', default => sub {+{map {$_ => 0}
                                                            LOW, HIGH}}),
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
            ++$self->sent->{$pulse};
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
}

{   package Module::Untyped;
    use Moo;
    extends 'Module';
    sub receive {}
}

my %TYPEMAP = (broadcaster => 'Broadcast',
               '%'         => 'FlipFlop',
               '&'         => 'Conjunction');
my $TYPE_RE = join '|', map quotemeta, keys %TYPEMAP;

my $c = 'Communication'->new;
while (<>) {
    chomp;
    my ($name, $destination) = split / -> /;
    my ($type) = $name =~ /($TYPE_RE)/;
    my $class = 'Module::' . $TYPEMAP{$type};
    $name =~ s/^[%&]//;
    $c->add_module($class->new(name        => $name,
                               destination => [split /, /, $destination]));
}

$c->initialise;
for (1 .. 1000) {
    $c->push_button;
    $c->step;
}

say $c->sent->{0} * $c->sent->{1};

__DATA__
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
