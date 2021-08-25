#!/usr/bin/env perl

# device_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to rsync data from each tower

use File::Path qw(make_path);
use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync::Licor;
use LicorSync::LicorDigest;

my $digest = '';
foreach my $tower (@{$LicorSync::Licor::towers}){
	my @timenow = localtime();
	if(not (exists $tower->{'infrequent'} and $tower->{'infrequent'} and $timenow[2]>=4) ){
		LicorSync::Licor::rsync_flat($tower);
	}

	if(exists $tower->{'digest'} and $tower->{'digest'} and not $timenow[2]>=4){
		$digest .= LicorSync::LicorDigest::digest($tower);
	}
}

if(not $digest eq ''){
	print $digest;
	my $subject = "Licor Data Digest";
	LicorSync::Licor::send_email($digest,$subject,$digest_config{'emails'});
}
