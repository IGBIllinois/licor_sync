#!/usr/bin/env perl
# licor.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Encapsulates the config files
use strict;
$|++;
package Licor;

use File::Path qw(make_path);
use YAML::Any qw(LoadFile);
use Data::Dumper;
use FindBin qw($Bin);
our $config = LoadFile($Bin . '/../etc/licor.yml');
our $towers = LoadFile($Bin . '/../etc/licor_towers.yml');
