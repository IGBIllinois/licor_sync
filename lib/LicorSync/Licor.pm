# licor.pl
# Author: Joe Leigh <jleigh@illinois.edu>
# Encapsulates the config files
package LicorSync::Licor;
use strict;
use warnings;

use File::Path qw(make_path);
use POSIX qw(strftime);
use Data::Dumper;
use FindBin qw($Bin);
use MIME::Lite;
use Email::MessageID;
use LicorSync::Config;

#Creates local dir for specified tower
sub create_local_dir {
	my $local_data_dir = shift;
	my $tower_name = shift;
	if(not -e "$local_data_dir/$tower_name/raw"){
                make_path("$local_data_dir/$tower_name/raw");
        }


}

#Runs rsync on tower when using flat directory structure, all data files in 1 directory
sub rsync_flat {
	my $tower = shift;
	my $rsync_options = shift;
	my @timenow = localtime();
	my $ip = $tower->{'ip'};
	my $data_dir = $tower->{'data_dir'};
	my $tower_name = $tower->{'name'};
	my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};
	print "\n".current_time()."Beginning rsync for $tower_name...\n";
	
	LicorSync::Licor::create_local_dir($tower_name,$local_data_dir);

	if (exists $tower->{'remove_source_files'} and $tower->{'remove_source_files'}) {
		$rsync_options .= "--remove-source-files ";
	}
	my $cmd = "/usr/bin/rsync -auv " . $rsync_options . "--timeout=1000 --chmod=Du=rwx,Dgo=rx,Fuog=r --include=*.ghg --exclude=* licor\@$ip:$data_dir $local_data_dir/$tower_name/raw";
	print $cmd . "\n";
	system $cmd;
	print "\n".current_time()."Done\n";

}

#Runs rsync on twoer when using directory sturcture, data files sorted by year/month
sub rsync_dir {
	my $tower = shift;
	my $rsync_options = shift;
        my @timenow = localtime();
	my $ip = $tower->{'ip'};
	my $data_dir = $tower->{'data_dir'};
	my $tower_name = $tower->{'name'};
	my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};
	print "\n".current_time()."Beginning rsync for $tower_name...\n";
	LicorSync::Licor::create_local_dir($tower_name,$local_data_dir);

	if (exists $tower->{'remove_source_files'} and $tower->{'remove_source_files'}) {
		$rsync_options .= "--remove-source-files ";
	}
	#my $cmd = "/usr/bin/rsync -auv ".$options."--timeout=1000 --chmod=o=r,g=r,u=r --include=*.ghg --exclude=* licor\@$ip:$data_dir $local_data_dir/$tower_name/raw";
	#my $cmd = "/usr/bin/rsync -auv ".$options."--timeout=1000 --include=*.ghg --exclude=* licor\@$ip:$data_dir $local_data_dir/$tower_name/raw";
	#print $cmd . "\n";
	#system $cmd;
	`chmod 755 $local_data_dir/$tower_name/raw`;
	print "\n".current_time()."Done\n";

}
sub current_time {
        return strftime("[%Y-%m-%d %H:%M:%S] ",localtime);
}

sub send_email {
        my $body = shift;
	my $subject = shift;
	my $to = shift;

        my $recipientArr = $to;
        my $recipientStr = join ",", @{$recipientArr};

        my $message = MIME::Lite->new(
                From => $LicorSync::Config::config->{email_from},
                To => $recipientStr,
                Subject => $subject,
                'Message-ID' => Email::MessageID->new->in_brackets,
                Data => $body,
                );

        $message->send('smtp',$LicorSync::Config::config->{smtp_host},Timeout=>60,Port=>$LicorSync::Config::config->{smtp_port});
}

1;

