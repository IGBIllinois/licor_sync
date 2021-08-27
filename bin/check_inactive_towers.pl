#!/usr/bin/env perl

# device_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2020 Institute for Genomic Biology
# 
# Script to check raw data for inactivity

use strict;
use warnings;

use POSIX;
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');
use LicorSync::Config;
use LicorSync::Licor;

my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};
my $inactivity_threshold = $LicorSync::Config::config->{'inactivity_threshold'};
my $now = time();

my $email_body = "";

foreach my $tower (@{$LicorSync::Config::towers}){
    my $tower_name = $tower->{'name'};
    my $raw_dir = "$local_data_dir/$tower_name/raw";
    my $latest_time = 0;
    opendir(my $raw_dh, $raw_dir);
    my @raw_files = readdir($raw_dh);
    closedir $raw_dh;
    foreach my $file (@raw_files){
        if(!($file =~ m/^\./m)){
            my $modify_time = (stat("$raw_dir/$file"))[9];
            if($modify_time > $latest_time){
                $latest_time = $modify_time;
            }
        }
    }
    if($latest_time > 0 && $now - $latest_time > $inactivity_threshold){
        my $days = floor(($now-$latest_time)/(60*60*24));
	    print "No data from $tower_name with IP addresss $tower->{'ip'} in $days days\n";
        $email_body = $email_body . "No data from $tower_name with IP address $tower->{'ip'} in $days days\n";
    } elsif($latest_time == 0){
	    print "No data from $tower_name with IP address $tower->{'ip'} in >6 months\n";
        $email_body = $email_body . "No data from $tower_name with IP addres $tower->{'ip'} in >6 months\n";
    }
}

if($email_body ne ""){
	my $from = $LicorSync::Config::config->{'email_from'};
	my $to = $LicorSync::Config::config->{'inactivity_email_to'};
	my $body = "The following licor tower(s) have not synced in a while:\n\n$email_body";
	my $subject = "Licor data not syncing";

	LicorSync::Licor::send_email($body,$subject,$to);
}

