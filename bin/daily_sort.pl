#!/usr/bin/perl

# daily_sort.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to archive licor data, organized by day, up until the day the daily script will be archiving

use YAML qw(LoadFile);
use String::Util qw(trim);
use File::Path qw(make_path);
use lib '/usr/local/licorSync/lib/perl';
use Licor;

my $local_data_dir = $Licor::config->{'local_data_dir'};

my $archive_day = trim(`date +"\%d" -d '7 days ago'`);
my $archive_month = trim(`date +"\%m" -d '7 days ago'`);
my $archive_year = trim(`date +"\%Y" -d '7 days ago'`);

my $archive_month_str = sprintf("%02d",$archive_month);
my $archive_day_str = sprintf("%02d",$archive_day);
	
foreach my $tower (@{$Licor::towers}){
	my $tower_name = $tower->{'name'};
	print "Archiving $tower_name...\n";
	
	my $tar_name = "$local_data_dir/$tower_name/compressed/$archive_year/$archive_month_str/$tower_name-$archive_year-$archive_month_str-$archive_day_str.tar.gz";
	print "\tArchiving $tower_name $archive_year/$archive_month_str/$archive_day_str... ";
	if(-f $tar_name){
		print "Already archived. Skipping.\n";
	} else {
		my @files_to_tar = glob("$local_data_dir/$tower_name/raw/$archive_year-$archive_month_str-$archive_day_str*");
		if(scalar(@files_to_tar) == 0){
			print "No files found. Skipping.\n";
		} else {
			make_path("$local_data_dir/$tower_name/compressed/$archive_year/$archive_month_str");
			# Tar up the data from 7 days ago
			`cd $local_data_dir/$tower_name/raw; tar -cvzf $tar_name $archive_year-$archive_month_str-$archive_day_str* 2>&1; cd -`;
			print "Done.\n";
		}
	}

	# Delete files once theyre 6+ months old
	`find $local_data_dir/$tower_name/raw -type f -mtime +180 -exec rm {} \\;`;
}