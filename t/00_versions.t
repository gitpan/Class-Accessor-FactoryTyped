#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;

BEGIN {
    my @dependencies;
    my $main_module;
    my $file = 'Makefile.PL';
    open my $fh, $file or BAIL_OUT("can't open $file: $!");
    while (<$fh>) {
        if (/^\s*(?:test_)?requires\s+(['"])([\w:]+)\1/) {
            push @dependencies => $2;
        } elsif (/^\s*name\s+(['"])([\w-]+)\1/) {
            ($main_module = $2) =~ s/-/::/g;
        }
    }
    $main_module        or BAIL_OUT("can't determine main module name");
    close $fh           or BAIL_OUT("can't close $file: $!");
    use_ok $main_module or BAIL_OUT("can't load $main_module");
    my $version = $main_module->VERSION;
    diag("Testing $main_module $version, Perl $], $^X");
    for my $module (@dependencies) {
        use_ok $module or BAIL_OUT("can't load $module");
        my $version = $module->VERSION;
        diag("    $module version is $version");
    }
    done_testing;
}
