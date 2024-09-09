package LicorSync;
use strict;
use warnings;

use constant VERSION => 1.2.1;
use constant SOURCE_URL => "https://github.com/IGBIllinois/licor_sync";

sub get_version {
	return VERSION;
}

sub get_source_url {
	return SOURCE_URL;
}
1;
