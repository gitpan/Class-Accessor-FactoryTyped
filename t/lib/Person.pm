package Person;

use warnings;
use strict;

use base 'Class::Accessor::FactoryTyped';

__PACKAGE__->mk_factory_typed_accessors(
    'MyFactory',
    person_name    => 'name',
    person_address => 'address',
);

1;
