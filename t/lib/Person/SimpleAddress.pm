package Person::SimpleAddress;
our $VERSION = '1.100830';
use warnings;
use strict;
use base 'Class::Accessor::Complex';
__PACKAGE__->mk_new->mk_scalar_accessors(qw(fulladdr));
1;
