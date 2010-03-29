package Person::SimpleName;
our $VERSION = '1.100880';
use warnings;
use strict;
use parent 'Class::Accessor::Complex';
__PACKAGE__->mk_new->mk_scalar_accessors(qw(fullname));
1;
