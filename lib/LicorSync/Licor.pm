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
use MIME::Lite;
use Email::MessageID;

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



sub send_email {
        my $body = shift;
	my $subject = shift;
	my $to = shift;

        my $recipientArr = $to;
        my $recipientStr = join ",", @{$recipientArr};

        my $message = MIME::Lite->new(
                From => $config->{email_from},
                To => $recipientStr,
                Subject => $subject,
                'Message-ID' => Email::MessageID->new->in_brackets,
                Data => $body,
                );

        $message->send('smtp',$config->{smtp_host},Timeout=>60,Port=>$config->{smtp_port});
}

