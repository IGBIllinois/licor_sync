#! /usr/bin/env perl
# remote_delete.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
#
# Script to remotely delete data older than 6 months from licor devices

use strict;
use warnings;

use String::Util qw(trim);
use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync::Licor;
use LicorSync::Config;

my $archive_month = trim(`date +"\%m" -d '6 months ago'`);
my $archive_year = trim(`date +"\%Y" -d '6 months ago'`);
my $archive_month_str = sprintf("%02d",$archive_month);

foreach my $tower (@{$LicorSync::Config::towers}){
	if(exists $tower->{'remove_old'} and $tower->{'remove_old'}){
		my $command = "ssh licor\@$tower->{ip} \"rm $tower->{data_dir}$archive_year/$archive_month_str/*\"";
		print "$command\n";
		`$command`;
	}
}
