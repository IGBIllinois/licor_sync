#!/usr/bin/env perl

# device_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to rsync data from each tower

use File::Path qw(make_path);
use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync;
use LicorSync::Licor;
use LicorSync::Digest;
use LicorSync::Config;
use Getopt::Long;

sub help() {
        print "Usage: $0\n";
	print "Runs rsync to transfer data from licor devices to local server\n";
	print LicorSync::get_source_url() . "\n";
        print "\t--dry-run        Does dry run only. No transferring of data\n";
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

my $rsync_options = "";
if ($dryrun) {
	$rsync_options = "--dry-run ";
}
my $digest = '';

foreach my $tower (@{$LicorSync::Config::towers}){
	my @timenow = localtime();
	if(not (exists $tower->{'infrequent'} and $tower->{'infrequent'} and $timenow[2]>=4) ){
		LicorSync::Licor::rsync_data($tower,$rsync_options);
	}

	if(exists $tower->{'digest'} and $tower->{'digest'} and not $timenow[2]>=4){
		$digest .= LicorSync::Digest::digest($tower);
	}
}

if(not $digest eq ''){
	print $digest;
	my $subject = "Licor Data Digest";
	if (!$dryrun) {
		LicorSync::Licor::send_email($digest,$subject,$digest_config{'emails'});
	}
}
