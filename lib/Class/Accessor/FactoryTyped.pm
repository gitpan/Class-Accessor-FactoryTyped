package Class::Accessor::FactoryTyped;

use warnings;
use strict;
use Carp 'croak';
use Data::Miscellany 'set_push';
use UNIVERSAL::require;


our $VERSION = '0.01';


use base 'Class::Accessor::Complex';


__PACKAGE__->mk_class_array_accessors(
    qw(factory_typed_accessors factory_typed_array_accessors)
);


sub mk_factory_typed_accessors {
    my ($self, $factory_class_name, @args) = @_;
    my $class = ref $self || $self;

    $factory_class_name->require or die $@;

    while (@args) {
        my $type = shift @args;
        my $list = shift @args or die "No slot names for $class";

        # Allow a list of hashrefs.
        my @list = ( ref($list) eq 'ARRAY' ) ? @$list : ($list);

        for my $obj_def (@list) {

            my ($name, @composites);
            my $new_meth = 'new';
            if ( ! ref $obj_def ) {
                $name = $obj_def;
            } else {
                $name = $obj_def->{slot};
                my $composites = $obj_def->{comp_mthds};
                @composites = ref($composites) eq 'ARRAY' ? @$composites
                    : defined $composites ? ($composites) : ();
            }

            for my $meth (@composites) {
                no strict 'refs';
                *{"${class}::${meth}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::{$meth}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self, @args) = @_;
                    $self->$name()->$meth(@args);
                };
            }

            my $expected_class;

            # use a class list to the target package to keep track of which
            # framework_objects the class has, for introspection purposes

            $self->factory_typed_accessors_push($name);

            no strict 'refs';
            *{"${class}::${name}"} = sub {
                local $DB::sub = local *__ANON__ = "${class}::${name}"
                    if defined &DB::DB && !$Devel::DProf::VERSION;
                my ($self, @args) = @_;

                unless ($expected_class) {
                    $expected_class =
                        $factory_class_name->get_registered_class($type);

                    die "no general class name for type [$type]"
                        unless $expected_class;

                    # need to load the class to do UNIVERSAL::isa stuff on the
                    # class name

                    $expected_class->require or die $@;
                }

                if (ref $args[0] eq $expected_class) {
                    return $self->{$name} = $args[0];

                } elsif (@args || !defined $self->{$name}) {

                    # We accept a hashref of args as well and have to deref it
                    # first, since we're going to push args onto the @args
                    # array.

                    @args = (scalar(@args == 1) && ref($args[0]) eq 'HASH')
                        ? %{ $args[0] } : @args;

                    # Create an object if args are given, or autovivify one if
                    # no args are given and it doesn't exist yet.

                    return $self->{$name} = $factory_class_name->
                        make_object_for_type($type, @args);
                }

                # Still here? Hm, shouldn't happen, but return the value anyway.
                $self->{$name};
            };


            *{"${class}::clear_${name}"} =
            *{"${class}::${name}_clear"} = sub {
                local $DB::sub = local *__ANON__ = "${class}::${name}_clear"
                    if defined &DB::DB && !$Devel::DProf::VERSION;
                $_[0]->{$name} = undef;
            };


            *{"${class}::exists_${name}"} =
            *{"${class}::${name}_exists"} = sub {
                local $DB::sub = local *__ANON__ = "${class}::${name}_exists"
                    if defined &DB::DB && !$Devel::DProf::VERSION;
                exists $_[0]->{$name};
            };
        }
    }

    $self;  # for chaining
}


sub mk_factory_typed_array_accessors {
    my ($self, $factory_class_name, @args) = @_;
    my $class = ref $self || $self;

    $factory_class_name->require or die $@;

    while (@args) {
        my $object_type_const = shift @args;
        my $list = shift @args or die "No slot names for $class";

        # Allow a list of hashrefs.
        my @list = ( ref($list) eq 'ARRAY' ) ? @$list : ($list);

        for my $field (@list) {
            my $normalize = "${field}_normalize";

            no strict 'refs';

            *{"${class}::${normalize}"} = sub {
                local $DB::sub = local *__ANON__ = "${class}::${normalize}"
                    if defined &DB::DB && !$Devel::DProf::VERSION;
                my $self = shift;
                map {
                    ref $_ ? $_ :
                        $factory_class_name->make_object_for_type(
                            $object_type_const, $_,
                        );
                }
                map { ref $_ eq 'ARRAY' ? @$_ : ($_) }
                @_;
            };

            # use a class list to the target package to keep track of which
            # framework_list_objects the class has, for introspection purposes

            $self->factory_typed_array_accessors_push($field);

            *{"${class}::${field}"} = sub {
                local $DB::sub = local *__ANON__ = "${class}::${field}"
                    if defined &DB::DB && !$Devel::DProf::VERSION;
                my $self = shift;
                defined $self->{$field} or $self->{$field} = [];
                @{$self->{$field}} = $self->$normalize(@_) if @_;
                wantarray ? @{$self->{$field}} : $self->{$field};
            };

            for my $name ("${field}_pop", "pop_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self) = @_;
                    pop @{$self->{$field}}
                };
            }

            for my $name ("${field}_set_push", "set_push_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self, @values) = @_;
                    set_push @{$self->{$field}}, $self->$normalize(@values);
                };
            }

            for my $name ("${field}_push", "push_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self, @values) = @_;
                    push @{$self->{$field}}, $self->$normalize(@values);
                };
            }

            for my $name ("${field}_shift", "shift_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self) = @_;
                    shift @{$self->{$field}}
                };
            }

            for my $name ("${field}_unshift", "unshift_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self, @values) = @_;
                    unshift @{$self->{$field}}, $self->$normalize(@values);
                };
            }

            for my $name ("${field}_splice", "splice_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self, $offset, $len, @list) = @_;
                    splice(@{$self->{$field}}, $offset, $len, @list);
                };
            }

            for my $name ("${field}_clear", "clear_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self) = @_;
                    @{$self->{$field}} = () ;
                };
            }

            for my $name ("${field}_count", "count_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self) = @_;
                    exists $self->{$field} ? scalar @{$self->{$field}} : 0;
                };
            }

            for my $name ("${field}_index", "index_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my $self = shift;
                    my (@indices) = @_;
                    my @Result;
                    push @Result, $self->{$field}->[$_] for @indices;
                    return $Result[0] if @_ == 1;
                    wantarray ? @Result : \@Result;
                };
            }

            for my $name ("${field}_set", "set_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my $self = shift;
                    my @args = @_;
                    croak "$name expects an even number of fields\n"
                        if @args % 2;
                    while ( my ($index, $value) = splice @args, 0, 2 ) {
                        $self->{$field}->[$index] = $self->$normalize($value);
                    }
                    return @_ / 2;
                };
            }

            for my $name ("${field}_ref", "ref_$field") {
                *{"${class}::${name}"} = sub {
                    local $DB::sub = local *__ANON__ = "${class}::${name}"
                        if defined &DB::DB && !$Devel::DProf::VERSION;
                    my ($self) = @_;
                    $self->{$field};
                };
            }
        }
    }

    $self;  # for chaining
}


1;


__END__

=head1 NAME

Class::Accessor::FactoryTyped - accessors whose values come from a factory

=head1 SYNOPSIS

    package Person;
    use base 'Class::Accessor::FactoryTyped';

    __PACKAGE__->mk_factory_typed_accessors(
        'My::Factory',
        person_name    => 'name',
        person_address => 'address',
    );

=head1 DESCRIPTION

This module generates accessors for your class in the same spirit as
L<Class::Accessor> does. While the latter deals with accessors for scalar
values, this module provides accessor makers for arrays, hashes, integers,
booleans, sets and more.

As seen in the synopsis, you can chain calls to the accessor makers. Also,
because this module inherits from L<Class::Accessor>, you can put a call
to one of its accessor makers at the end of the chain.

=head1 ACCESSORS

This section describes the accessor makers offered by this module, and the
methods it generates.

=head2 mk_factory_typed_accessors

    MyClass->mk_factory_typed_accessors(
        'My::Factory',
        foo => 'phooey',
        bar => [ qw(bar1 bar2 bar3) ],
        baz => {
            slot => 'foo',
            comp_mthds => [ qw(bar baz) ]
        },
        fob => [
            {
                slot       => 'dog',
                comp_mthds => 'bark',
            },
            {
                slot       => 'cat',
                comp_mthds => 'miaow',
            },
        ],
    );


This behaves a lot like C<Class::Accessor::Complex>'s
C<mk_object_accessors()>, but the types of objects - that is, their class
names - that the generated accessors can take aren't given statically, but are
determined by asking a factory.

The factory class name must be the first argument. The class indicated should
be a subclass of L<Class::Factory::Enhanced>.

The following argument is an array which should contain pairs of class =>
sub-argument pairs. The sub-arguments parsed thus:

=over 4

=item Hash Reference

See C<baz()> above. The hash should contain the following keys:

=over 4

=item slot

The name of the instance attribute (slot).

=item comp_mthds

A string or array reference, naming the methods that will be forwarded
directly to the object in the slot.

=back

=item Array Reference

As for C<String>, for each member of the array. Also works if each member is a
hash reference (see C<fob()> above).

=item String

The name of the instance attribute (slot).

=back

For each slot C<x>, with forwarding methods C<y()> and C<z()>, the following
methods are created:

=over 4

=item x

A get/set method, see C<*> below.

=item y

Forwarded onto the object in slot C<x>, which is auto-created via C<new()> if
necessary. The C<new()>, if called, is called without arguments.

=item z

As for C<y>.

=back

So, using the example above, a method, C<foo()>, is created, which can get and
set the value of those objects in slot C<foo>, which will generally contain an
object of the type the factory, in this case C<My::Factory>, uses for the
object type C<baz>. Two additional methods are created named C<bar()> and
C<baz()> which result in a call to the C<bar()> and C<baz()> methods on the
Baz object stored in slot C<foo>.

Apart from the forwarding methods described above, C<mk_object_accessors()>
creates methods as described below, where C<*> denotes the slot name.

=over 4

=item C<*>

If the accessor is supplied with an object of an appropriate type, will set
set the slot to that value. Else, if the slot has no value, then an object is
created by calling C<new()> on the appropriate class, passing in any supplied
arguments.

The stored object is then returned.

=item C<*_clear>, C<clear_*>

Removes the object from the accessor.

=back

=head2 mk_factory_typed_array_accessors

Like C<mk_factory_typed_accessors()> except creates array accessors with all
methods like those generated by C<Class::Accessor::Complex>'s
C<mk_array_accessors()>.

TODO: More documentation is needed, but this is an early release.

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<classaccessorfactorytyped> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-class-accessor-factorytyped@rt.cpan.org>, or through the web interface
at L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

