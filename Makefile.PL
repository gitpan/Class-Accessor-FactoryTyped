
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Class::Accessor::FactoryTyped',
                       'DISTNAME' => 'Class-Accessor-FactoryTyped',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.11'
                                               },
                       'AUTHOR' => 'Marcel Gruenauer <marcel@cpan.org>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'Accessors whose values come from a factory',
                       'EXE_FILES' => [],
                       'VERSION' => '1.100880',
                       'PREREQ_PM' => {
                                        'Class::Accessor::Complex' => '0',
                                        'Scalar::Util' => '0',
                                        'English' => '0',
                                        'parent' => '0',
                                        'Data::Miscellany' => '0',
                                        'FindBin' => '0',
                                        'Class::Accessor::Installer' => '0',
                                        'Carp' => '0',
                                        'Test::More' => '0.88',
                                        'Class::Factory::Enhanced' => '0',
                                        'File::Find' => '0',
                                        'File::Temp' => '0',
                                        'UNIVERSAL::require' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



