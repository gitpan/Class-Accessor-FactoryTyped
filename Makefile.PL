use inc::Module::Install;
include 'Module::AutoInstall';

name 'Class-Accessor-FactoryTyped';
all_from 'lib/Class/Accessor/FactoryTyped.pm';
perl_version '5.006';

requires 'Class::Accessor';
requires 'Class::Accessor::Installer';
requires 'Class::Factory::Enhanced';
requires 'Data::Miscellany';
requires 'UNIVERSAL::require';

build_requires 'Test::More' => '0.70';

process_templates(
    first_year => 2007,
    rest_from  => "$ENV{HOME}/.mitlib/standard_pod",
    start_tag  => '{%',
    end_tag    => '%}',
);

use_standard_tests(without => 'pod_coverage');
auto_install;
auto_include;
WriteAll;
