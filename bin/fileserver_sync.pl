#!/usr/bin/env perl

# fileserver_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to rsync data from local folder to file-server

use YAML qw(LoadFile);
use File::Path qw(make_path);
use POSIX qw(strftime);
use FindBin qw($Bin);
use lib $Bin . '/../lib/perl';
use Licor;

sub current_time {
	return strftime("[%Y-%m-%d %H:%M:%S] ",localtime);
}

my $local_data_dir = $Licor::config->{'local_data_dir'};
my $backup_data_dir = $Licor::config->{'backup_data_dir'};
my $backup_server = $Licor::config->{'backup_server'};
my $backup_user = $Licor::config->{'backup_user'};
	
foreach my $tower (@{$Licor::towers}){
	my $tower_name = $tower->{'name'};
	print "\n".current_time()."Beginning rsync for $tower_name...\n";

	my $cmd =  "/usr/bin/rsync --chmod=D2770,F660 --ignore-existing -rtuv --timeout=1000 $local_data_dir/$tower_name/compressed $backup_user\@$backup_server:$backup_data_dir/$tower_name/\n";
	print $cmd;
	system $cmd;

	print "\n".current_time()."Done\n";
}

