# LicorDigest.pm
# Author: Joe Leigh <jleigh@illinois.edu>
# Parses the last line of a licor data file for inclusion in a nightly digest

package LicorSync::Digest;
use strict;
use warnings;

use File::Path qw(make_path);
use FindBin qw($Bin);
use LicorSync::Config;

sub noon_file {
	my $tower = shift;
	# Find most recent ghg file
	my @filetimes = ('120000','123000','130000');
	my @timenow = localtime(time-60*60*24);
	my $year = $timenow[5]+1900;
	my $month = sprintf('%02d',$timenow[4]+1);
	my $day = sprintf('%02d',$timenow[3]);
	my $filename = $year.'-'.$month.'-'.$day.'T'.$filetimes[0].'_'.$tower->{file_name};
	return $filename;
}

sub digest {
	my $tower = shift;

	if(not -e "licor_tmp"){
		make_path("licor_tmp");
	}

	# TODO pull from config file
	my $columns = $LicorSync::Config::digest_config->{columns};

	my $data_dir = "/home/shared/licor_data/".$tower->{name}."/raw/";
	my $ghgFileName = LicorDigest::noon_file($tower);
	if(-e "$data_dir$ghgFileName.ghg"){

		`cd licor_tmp; unzip -o $data_dir$ghgFileName.ghg`;
		my $dataFilePath = 'licor_tmp/'.$ghgFileName.'.data';

		open my $dataFh, '<', $dataFilePath;
		# Get instrument name
		for (my $i = 0; $i < 2; $i++) {
			<$dataFh>;
		}
		my $instrumentline = <$dataFh>;
		chomp $instrumentline;

		# Get column headers
		for (my $i = 3; $i < 7; $i++) {
			<$dataFh>;
		}
		my $headerline = <$dataFh>;
		chomp $headerline;
		my @headerArr = split "\t", $headerline;

		# Initialize column stats
		my @min;
		my @max;
		my @mean;
		my $firstdataline = <$dataFh>;
		chomp $firstdataline;
		my @firstdataArr = split "\t", $firstdataline;
		foreach my $col (@{$columns}){
			$min[$col->{column}] = $firstdataArr[$col->{column}];
			$max[$col->{column}] = $firstdataArr[$col->{column}];
			$mean[$col->{column}] = $firstdataArr[$col->{column}];
		}
		# Aggregate stats
		my $linenum = 2;
		while(my $dataline = <$dataFh>){
			chomp $dataline;
			my @dataArr = split "\t", $dataline;
			foreach my $col(@{$columns}){
				if($dataArr[$col->{column}]<$min[$col->{column}]){
					$min[$col->{column}] = $dataArr[$col->{column}];
				}
				if($dataArr[$col->{column}]>$max[$col->{column}]){
					$max[$col->{column}] = $dataArr[$col->{column}];
				}
				$mean[$col->{column}] *= $linenum-1;
				$mean[$col->{column}] += $dataArr[$col->{column}];
				$mean[$col->{column}] /= $linenum;
			}
			$linenum++;
		}

		# Print information
		my $info = $tower->{name}." digest:\n".$instrumentline."\n";
		foreach my $col (@{$columns}) {
			if($col->{round}>=0){
				$info = $info . $headerArr[$col->{column}]." - Min: ".sprintf("%2.$col->{round}f",$min[$col->{column}])." Max: ".sprintf("%2.$col->{round}f",$max[$col->{column}])." Mean: ".sprintf("%2.$col->{round}f",$mean[$col->{column}])."\n";
			} else {
				$info = $info . $headerArr[$col->{column}]." - ".$min[$col->{column}]."\n";
			}
		}
		return $info."\n";
	} else {
		return "Data not found for ".$tower->{name}."\n\n";
	}
}

1;
