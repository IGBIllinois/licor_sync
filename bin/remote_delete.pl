#! /usr/bin/perl

use String::Util qw(trim);
use lib '/usr/local/licorSync/lib/perl';
use Licor;

my $archive_month = trim(`date +"\%m" -d '6 months ago'`);
my $archive_year = trim(`date +"\%Y" -d '6 months ago'`);
my $archive_month_str = sprintf("%02d",$archive_month);

foreach my $tower (@{$Licor::towers}){
	if(exists $tower->{'remove_old'} and $tower->{'remove_old'}){
		my $command = "ssh licor\@$tower->{ip} \"rm $tower->{data_dir}$archive_year-$archive_month_str*\"";
		print "$command\n";
		`$command`;
	}
}