#!/usr/bin/env perl

# fileserver_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to rsync data from local folder to file-server

use strict;
use warnings;

use File::Path qw(make_path);
use POSIX qw(strftime);
use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync::Licor;
use LicorSync::Config;

sub current_time {
	return strftime("[%Y-%m-%d %H:%M:%S] ",localtime);
}

my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};
my $backup_data_dir = $LicorSync::Config::config->{'backup_data_dir'};
my $backup_server = $LicorSync::Config::config->{'backup_server'};
my $backup_user = $LicorSync::Config::config->{'backup_user'};
	
foreach my $tower (@{$LicorSync::Config::towers}){
	my $tower_name = $tower->{'name'};
	print "\n".current_time()."Beginning rsync for $tower_name...\n";

	my $cmd =  "/usr/bin/rsync --chmod=D2750,F640 --ignore-existing -rtuv --timeout=1000 $local_data_dir/$tower_name/compressed $backup_user\@$backup_server:$backup_data_dir/$tower_name/\n";
	print $cmd;
	system $cmd;

	print "\n".current_time()."Done\n";
}

