#!/usr/bin/env perl

# device_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to rsync data from each tower

use YAML qw(LoadFile);
use File::Path qw(make_path);
use POSIX qw(strftime);
use FindBin qw($Bin);
use lib $Bin . '/../lib/perl';
use Licor;
use LicorDigest;
use Data::Dumper;

sub current_time {
	return strftime("[%Y-%m-%d %H:%M:%S] ",localtime);
}

my $digest = '';
my $local_data_dir = $Licor::config->{'local_data_dir'};
	
foreach my $tower (@{$Licor::towers}){
	my @timenow = localtime();
	if(not (exists $tower->{'infrequent'} and $tower->{'infrequent'} and $timenow[2]>=4) ){
		my $ip = $tower->{'ip'};
		my $data_dir = $tower->{'data_dir'};
		my $tower_name = $tower->{'name'};
		print "\n".current_time()."Beginning rsync for $tower_name...\n";
		if(not -e "$local_data_dir/$tower_name/raw"){
			make_path("$local_data_dir/$tower_name/raw");
		}

		my $options = "";
		if (exists $tower->{'remove_source_files'} and $tower->{'remove_source_files'}) {
			$options = "--remove-source-files ";
		}
		print "/usr/bin/rsync -auv ".$options."--timeout=1000 --chmod=o=r,g=r,u=r --include=*.ghg --exclude=* licor\@$ip:$data_dir $local_data_dir/$tower_name/raw\n";
		system "/usr/bin/rsync -auv ".$options."--timeout=1000 --chmod=o=r,g=r,u=r --include=*.ghg --exclude=* licor\@$ip:$data_dir $local_data_dir/$tower_name/raw";
		`chmod 755 $local_data_dir/$tower_name/raw`;
		print "\n".current_time()."Done\n";
	}

	if(exists $tower->{'digest'} and $tower->{'digest'} and not $timenow[2]>=4){
		$digest .= LicorDigest::digest($tower);
	}
}

if(not $digest eq ''){
	print $digest;
	LicorDigest::emailDigest($digest);
}
