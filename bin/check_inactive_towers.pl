#!/usr/bin/env perl

# device_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2020 Institute for Genomic Biology
# 
# Script to check raw data for inactivity

use POSIX;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib', 'perl');
use Licor;

my $local_data_dir = $Licor::config->{'local_data_dir'};
my $inactivity_threshold = $Licor::config->{'inactivity_threshold'};
my $now = time();

my $email_body = "";

foreach my $tower (@{$Licor::towers}){
    my $tower_name = $tower->{'name'};
    my $raw_dir = "$local_data_dir/$tower_name/raw";
    my $latest_time = 0;
    opendir(my $raw_dh, $raw_dir);
    my @raw_files = readdir($raw_dh);
    closedir $raw_dh;
    foreach my $file (@raw_files){
        if(!($file =~ m/^\./m)){
            my $modify_time = (stat("$raw_dir/$file"))[9];
            # print "$file: \t$modify_time\n";
            if($modify_time > $latest_time){
                $latest_time = $modify_time;
            }
        }
    }
    if($latest_time > 0 && $now - $latest_time > $inactivity_threshold){
        my $days = floor(($now-$latest_time)/(60*60*24));
	    print "No data from $tower_name in $days days\n";
        $email_body = $email_body . "No data from $tower_name in $days days\n";
    } elsif($latest_time == 0){
	    print "No data from $tower_name in >6 months\n";
        $email_body = $email_body . "No data from $tower_name in >6 months\n";
    }
}

if($email_body ne ""){
    my $from = $Licor::config->{'inactivity_email_from'};
    my $to = $Licor::config->{'inactivity_email_to'};
    my $message = Email::MIME->create(
        header_str => [
            From => $from,
            To => $to,
            Subject => 'Licor data not syncing',
        ],
        attributes => {
            encoding => 'quoted-printable',
            charset => 'ISO-8859-1',
        },
        body_str => "The following licor tower(s) have not synced in a while:\n\n$email_body",
    );

    sendmail($message);
}

