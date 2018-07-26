#!/usr/bin/perl
# licor.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Encapsulates the config files
use strict;
$|++;
package Licor;

use File::Path qw(make_path);
use YAML::Any qw(LoadFile);
use Data::Dumper;

our $config = LoadFile('/usr/local/licorSync/etc/licor.yml');
our $towers = LoadFile('/usr/local/licorSync/etc/licor_towers.yml');