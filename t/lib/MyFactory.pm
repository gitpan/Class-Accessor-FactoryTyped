package MyFactory;
our $VERSION = '1.100830';
use warnings;
use strict;
use base 'Class::Factory::Enhanced';

# Default mappings
__PACKAGE__->register_factory_type(
    person_name    => 'Person::SimpleName',
    person_address => 'Person::SimpleAddress',
);
1;
