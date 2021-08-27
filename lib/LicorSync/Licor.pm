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
	my $tower_name = shift;
	my $local_data_dir = shift;
	if(not -e "$local_data_dir/$tower_name/raw"){
                make_path("$local_data_dir/$tower_name/raw");
        }


}

sub rsync_data {
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
	my $cmd = "/usr/bin/rsync -auv " . $rsync_options . "--timeout=1000 --chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r --include \"*/\" --include=*.ghg --exclude='*' licor\@$ip:$data_dir $local_data_dir/$tower_name/raw";
	print $cmd . "\n";
	system $cmd;
	print "\n".current_time()."Done\n";

}

sub gzip_data {
	my $tower = shift;
	my $archive_year = shift;
	my $archive_month = shift;
	my $archive_day = shift;
	my $dryrun = shift;
	my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};
	my $tower_name = $tower->{'name'};
	print "Archiving $tower_name...\n";

	my $tar_name = "$local_data_dir/$tower_name/compressed/$archive_year/$archive_month/$tower_name-$archive_year-$archive_month-$archive_day.tar.gz";
	print "\tArchiving $tower_name $archive_year/$archive_month/$archive_day... ";
	if(-f $tar_name){
		print "Already archived. Skipping.\n";
	} else {
		my @files_to_tar_flat = glob("$local_data_dir/$tower_name/raw/$archive_year-$archive_month-$archive_day*");
		my @files_to_tar_dir = glob("$local_data_dir/$tower_name/raw/$archive_year/$archive_month/$archive_year-$archive_month-$archive_day*");
		if(scalar(@files_to_tar) == 0){
			print "No files found. Skipping.\n";
		}
		else {
			make_path("$local_data_dir/$tower_name/compressed/$archive_year/$archive_month");
			#Tar up the data from 7 days ago
			#`cd $local_data_dir/$tower_name/raw; tar -cvzf $tar_name $archive_year-$archive_month_str-$archive_day_str* 2>&1; cd -`;
			my $file_list = join(' ',@files_to_tar);
			my $cmd = "tar -cvzf $tar_name $file_list 2>&1;";
			print $cmd . "\n";
			if (!$dryrun) {
				system $cmd;
			}
			print "Done.\n";
		}

	}
}

sub delete_data {
	my $tower = shift;
	my $days_old = shift;
	my $dryrun = shift;
	my $tower_name = $tower->{'name'};
	my $local_data_dir = $LicorSync::Config::config->{'local_data_dir'};
	my $cmd = "find $local_data_dir/$tower_name/raw -type f -mtime +$days_old -exec rm {} \\;";
	print $cmd . "\n";
	if (!$dryrun) {
		system $cmd;
	}
	

}
sub current_time {
        return strftime("[%Y-%m-%d %H:%M:%S] ",localtime);
}

sub send_email {
        my $body = shift;
	my $subject = shift;
	my $to = shift;

        my $message = MIME::Lite->new(
                From => $LicorSync::Config::config->{email_from},
                To => $to,
                Subject => $subject,
                'Message-ID' => Email::MessageID->new->in_brackets,
                Data => $body,
                );

        if ($message->send('smtp',$LicorSync::Config::config->{smtp_host},Timeout=>60,Port=>$LicorSync::Config::config->{smtp_port})) {
		print "Email successfully sent to " . $to . "\n";
	}

}

1;

