# licor.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Encapsulates the config files
use strict;
use warnings;

#$|++;
package LicorSync::Licor;

use File::Path qw(make_path);
use YAML::Any qw(LoadFile);
use Data::Dumper;
use FindBin qw($Bin);

use constant LICOR_CONFIG => 'licor.yml';
use constant LICOR_TOWERS_CONFIG => 'licor_towers.yml';

unless (-e $Bin . '/../etc/' . LICOR_CONFIG) {
	print "Config file /etc/" . LICOR_CONFIG . " does not exist\n";
	exit 1;
}
our $config = LoadFile($Bin . '/../etc/' . LICOR_CONFIG);

unless (-e $Bin . '/../etc/' . LICOR_TOWERS_CONFIG) {
	print "Config file /etc/" . LICOR_TOWERS_CONFIG . " does not exist\n";
	exit 1;
}
our $towers = LoadFile($Bin . '/../etc/' . LICOR_TOWERS_CONFIG);

