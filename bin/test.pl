#!/usr/bin/env perl

# device_sync.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Copyright 2016 Institute for Genomic Biology
# 
# Script to rsync data from each tower

use strict;
use warnings;

use YAML qw(LoadFile);
use File::Path qw(make_path);
use POSIX qw(strftime);
use FindBin qw($Bin);
use lib $Bin . '/../lib';
use LicorSync::Licor;
use LicorSync::LicorDigest;

my $message = "test";

my $subject = "Test Subject";
my $to = ["dslater\@igb.illinois.edu"];

#LicorSync::Licor::send_email($message,$subject,$to);
