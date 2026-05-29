#! /usr/bin/env perl
# remote_delete.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
#
# Script to remotely delete data from licor devices

use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync;
use LicorSync::Licor;
use LicorSync::Config;
use Getopt::Long;

sub help() {
        print "Usage: $0\n";
        print "Deletes data from licor devices older than 6 months\n";
        print LicorSync::get_source_url() . "\n";
        print "\t--dry-run        Does dry run only. No deleting of data\n";
        print "\t-v|--version        Print version\n";
        print "\t-h|--help           Prints this help\n";
        exit 0;
}

my $dryrun = 0;
my $version = 0;
GetOptions ("dry-run" => \$dryrun,
        "h|help" => sub { help() },
        "v|version" => \$version
) or die("\n");

if ($version) {
        print LicorSync::get_version() . "\n";
        exit 0;
}

foreach my $tower (@{$LicorSync::Config::towers}){
	LicorSync::Licor::delete_remote_data($tower,$dryrun);
}
