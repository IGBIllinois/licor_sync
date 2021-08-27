#!/usr/bin/env perl

# daily_sort.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to archive licor data, organized by day, up until the day the daily script will be archiving

use strict;
use warnings;

use String::Util qw(trim);
use File::Path qw(make_path);
use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync::Licor;
use LicorSync::Config;
use LicorSync;
use Getopt::Long;

sub help() {
        print "Usage: $0\n";
        print "gzips data from a single day into a tar.gz archive\n";
        print LicorSync::get_source_url() . "\n";
	print "\t--days-old	 Number of days old (Default: 7)\n";
        print "\t--dry-run        Does dry run only\n";
        print "\t-v|--version        Print version\n";
        print "\t-h|--help           Prints this help\n";
        exit 0;
}
my $deletedaysold = 180;
my $daysold = 7;
my $dryrun = 0;
my $version = 0;
GetOptions ("days-old=i" => \$daysold,
	"dry-run" => \$dryrun,
        "h|help" => sub { help() },
        "v|version" => \$version
) or die("\n");

if ($version) {
        print LicorSync::get_version() . "\n";
        exit 0;
}


my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};

my $archive_day = trim(`date +"\%d" -d '$daysold days ago'`);
my $archive_month = trim(`date +"\%m" -d '$daysold days ago'`);
my $archive_year = trim(`date +"\%Y" -d '$daysold days ago'`);

my $archive_month_str = sprintf("%02d",$archive_month);
my $archive_day_str = sprintf("%02d",$archive_day);
foreach my $tower (@{$LicorSync::Config::towers}){
	LicorSync::Licor::gzip_data($tower,$archive_year,$archive_month_str,$archive_day_str,$dryrun);
	LicorSync::Licor::delete_data($tower,$deletedaysold,$dryrun);
}
