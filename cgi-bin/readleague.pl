#!$$perl_command$$
##############################################################################
# Readleague.pl - Read League Parameters                                     #
# Copyright 1997 Gregory A Greenman                                          #
# Created 02/03/1997              Last Modified 02/17/2003 by vk             #
##############################################################################

my $leaguefile  = "$data_dir/league.txt";

my ($name, $value);

open (LFILE, $leaguefile);
my @llines = <LFILE>;
close (LFILE);

foreach (@llines) 
{
	# ignore leading whitespace, catch all non-tilde characters as the key,
	# ignore trailing whitespace, and everything else is the value
	if(/\s*([^~]*)~(.*)\s*/) { $league{$1} = $2; }
}

1;
