#!/usr/bin/perl

# daily_sort.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to archive licor data, organized by day, up until the day the daily script will be archiving
use strict;
use YAML qw(LoadFile);
use String::Util qw(trim);
use File::Path qw(make_path);
use lib '/usr/local/licorSync/lib/perl';
use Licor;
use Data::Dumper;

my $local_data_dir = $Licor::config->{'local_data_dir'};

my $archive_day = trim(`date +"\%d" -d '7 days ago'`);
my $archive_month = trim(`date +"\%m" -d '7 days ago'`);
my $archive_year = trim(`date +"\%Y" -d '7 days ago'`);

foreach my $tower (@{$Licor::towers}){
	my $tower_name = $tower->{'name'};
	print "Archiving $tower_name...\n";
	my @tower_files = glob("$local_data_dir/$tower_name/raw/*");
	my $earliest_year = $archive_year;
	my $earliest_month = $archive_month;
	my $earliest_day = $archive_day;
	foreach(@tower_files){
		if($_ =~ m/([^\/]+?)-([^\/]+?)-([^\/]+?)T[^\/]+$/){
			if($1<$earliest_year || ($1==$earliest_year&&$2<$earliest_month) || ($1==$earliest_year && $2==$earliest_month && $3<$earliest_day) ){
				$earliest_day = $3;
				$earliest_month = $2;
				$earliest_year = $1;
			}
		}
	}
	while($earliest_year<$archive_year || ($earliest_year==$archive_year && $earliest_month<$archive_month) || ($earliest_year==$archive_year && $earliest_month==$archive_month && $earliest_day<$archive_day)){
		my $earliest_month_str = sprintf("%02d",$earliest_month);
		my $earliest_day_str = sprintf("%02d",$earliest_day);
		my $tar_name = "$local_data_dir/$tower_name/compressed/$earliest_year/$earliest_month_str/$tower_name-$earliest_year-$earliest_month_str-$earliest_day_str.tar.gz";
		
		if(-f $tar_name){
			# print "Already archived. Skipping.\n";
		} else {
			my @files_to_tar = glob("$local_data_dir/$tower_name/raw/$earliest_year-$earliest_month_str-$earliest_day_str*");
			if(scalar(@files_to_tar) == 0){
				# print "No files found. Skipping.\n";
			} else {
				print "\tArchiving $tower_name $earliest_year/$earliest_month_str/$earliest_day_str... ";
				make_path("$local_data_dir/$tower_name/compressed/$earliest_year/$earliest_month_str");
				# Tar up the data from 7 days ago
				`cd $local_data_dir/$tower_name/raw; tar -cvzf $tar_name $earliest_year-$earliest_month_str-$earliest_day_str* 2>&1; cd -`;
				print "Done.\n";
			}
		}
		$earliest_day = $earliest_day+1;
		if($earliest_day == 32){
			$earliest_day = 1;
			$earliest_month = $earliest_month+1;
			if($earliest_month == 13){
				$earliest_month = 1;
				$earliest_year = $earliest_year + 1;
			}
		}
	}
}