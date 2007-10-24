use inc::Module::Install;
name 'Class-Accessor-FactoryTyped';
all_from 'lib/Class/Accessor/FactoryTyped.pm';
perl_version '5.006';

requires 'Class::Accessor';
requires 'Class::Accessor::Installer';
requires 'Class::Factory::Enhanced';
requires 'Data::Miscellany';
requires 'UNIVERSAL::require';

build_requires 'Test::More' => '0.70';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
