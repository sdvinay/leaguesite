#!$$perl_command$$

# $Revision: 1.10 $
# $Date: 2003-03-05 17:42:06-08 $

umask(0000);

$cgi_dir = "$$_cgi-bin_loc$$";
$cgi_url = "$$_cgi-bin_url$$";
$data_dir = "$$_data_loc$$";
$data_url = "$$_data_url$$";
$css_url = "$$_css_url$$";
$genhtml_dir = "$$_generated_html_loc$$";
$genhtml_url = "$$_generated_html_url$$";
$image_url = "$$_images_url$$";
$php_url = "$$_php_url$$";
$statichtml_dir = "$$_static_html_loc$$";
$statichtml_url = "$$_static_html_url$$";
  
$teamdir     = $genhtml_dir;
$rlfile      = "$cgi_dir/readleague.pl";
$team_file   = "$data_dir/teams.txt";
$stat_file   = "$data_dir/stat.txt";
$lockfile	 = "$data_dir/lock.txt";
$atempfile   = "$data_dir/auctinprog.wait";
$btempfile   = "$data_dir/bidinprog.wait";
$dtempfile   = "$data_dir/droneinprog.wait";
$leaguefile  = "$data_dir/league.txt";
$fafile      = "$data_dir/fagent.txt";
$foot_file   = "$statichtml_dir/foots.html";
$foots_file  = "$statichtml_dir/foots.html";
$footp_file  = "$statichtml_dir/footp.html";
$div_file    = "$data_dir/divisions.txt";
$sfile       = "$data_dir/sold.txt";
$stathtml    = "$genhtml_dir/stat.html";
$auctionhtml = "$genhtml_dir/auction.html";
$availhtml   = "$genhtml_dir/available.html";
$soldhtml    = "$genhtml_dir/sold.html";
$teamhtml    = "$genhtml_dir/teams.html";
$tradehtml   = "$genhtml_dir/trades.html";
$stat_bak    = "$data_dir/stat.bak";
$team_bak    = "$data_dir/teams.bak";
$bfile       = "$data_dir/bids.txt";
$faclaim     = "$data_dir/faclaim.txt";
$relfile     = "$data_dir/release.txt";
$tradefile   = "$data_dir/trade.txt";
$runfile     = "$data_dir/auctrun.txt";
$expense_file = "$data_dir/expenses.csv";
$releasehtml = "$genhtml_dir/released.html";
$faclaimhtml = "$genhtml_dir/claims.html";
$teamsurl    = "$genhtml_url/teams.php";
$htpasswdfile = "$$_data_loc$$/.htpasswd";

$auctstaturl = $genhtml_url . "/auction.html";
$availurl	 = $genhtml_url . "/available.html";
$bidurl      = $statichtml_url . "/bidpage.php";
$bidhistoryurl = $php_url . "/bidhistory.php";

require $rlfile;

$kMinPlayerNum = 10000;

# first arg is title/h2
# second arg is whether this is cgi (as opposed as output to html file)
# second arg is optional, assumed true
sub printhtmlheader
{
	my $title = shift(@_);
	print "Content-type: text/html\n\n" unless (scalar(@_) && $_[0] == 0);
	print "<html><head><title>$title</title>\n";
	print "<link rel=\"stylesheet\" href=\"$$_css_url$$/main.css\" type=\"text/css\">\n";
	print "</head>\n";
	print "<body>\n";
	print "<center><h2>$league{'name'}</h2>\n";
	print "<h3>$title</h3>\n";
	print "<hr>\n";
}

sub printhtmlfooter
{
	print "</body></html>\n";
}

sub prnt_footer {
   open(FOOTER,"$foot_file") || &error(sys_file);
   @flines = <FOOTER>;
   close(FOOTER);

   foreach $fline (@flines) {
      print "$fline";
   }
}

###########################################################################
sub prnt_sfooter {
   open(FOOTER,"$foots_file") || &error('Cannot open footer file');
   @flines = <FOOTER>;
   close(FOOTER);

   foreach $fline (@flines) {
      print "$fline";
   }
}


###########################################################################
sub prnt_pfooter {
   open(FOOTER,"$footp_file") || &error('Cannot Open Footer File');
   @flines = <FOOTER>;
   close(FOOTER);

   foreach $fline (@flines) {
      print "$fline";
   }
}

###########################################################################
sub waste {
   print "Content-type: text/html\n\n";
   print "<html><head><title>Waste</title></head>\n";
   print "<body><center><h1>You Are Wasting My Time!!!</h1></center>\n";
   print "</center><hr><p>\n";
   print "\$command = \"$command\"";
   print "</body></html>\n";
}




###########################################################################
sub error 
{
	&unlock();
	$error = $_[0];
	
	print "Content-type: text/html\n\n";
	print "<html><head><title>$$league_name$$</title></head>\n";
	print "<body><center><h1>$$league_name$$</h1></center>\n";
	print "<h2>Error:</h2><br>\n";
	print "$error\n";
	
	print "<!--\n";
	foreach $key (keys(%ENV))
	{
		print "$key => $ENV{$key} <br> \n";
	}
	print "-->\n";
	print "</body></html>\n";
	
	
	exit;
}

###########################################################################
# Parse Form Subroutine

sub parse_form {
	my $ignore_empties = ($#_ > 0) ? $_[0] : 1;
	
	my $inputstr;
	my $req_method = $ENV{'REQUEST_METHOD'};
	if ($req_method eq 'GET') 
	{
		$inputstr = $ENV{'QUERY_STRING'};
	}
	elsif ($req_method eq 'POST') 
	{
		read(STDIN, $inputstr, $ENV{'CONTENT_LENGTH'});
	}
	else 
	{
		&error("unknown request_method: $req_method");
	}
		
	# Split the name-value pairs
	@pairs = split(/&/, $inputstr);

	foreach $pair (@pairs) 
	{
		($name, $value) = split(/=/, $pair);
		
		# Un-Webify plus signs and %-encoding
		$value =~ tr/+/ /;
		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		
		if ($ignore_empties || $value) { $FORM{$name} = $value; }
	}
	
	return 1;
}

###########################################################################
sub waste 
{
	&error("waste");
}

###########################################################################
# first arg is username (i.e., team #)
# second arg is password
sub UpdateHTPasswd
{
	$cmd = "$$htpasswd_loc$$ -b $htpasswdfile $_[0] $_[1]";
	$ret = system($cmd);
	if (($ret == -1) || ($ret >> 8)) { return 0; }
	return 1;
}

# like php's trim function, this strips whitespace from
# the beginning and end of a string
# safer than chop
sub trim
{
	$str = $_[0];
	$str =~ s/^\s*(.*[^\s])\s*$/\1/g;
	return $str;
}

# this is an all-purpose lock, which should be acquired
#  before reading or writing any data/html files
# implemented by touching a file
# first arg is timeout in sec, default value is 4
sub lock
{
	my $sleepcount = 0;
	my $timeout = $_[0] ? $_[0] : 4;

	while (!(&trylock()) && ($sleepcount < $timeout)) 
	{
		sleep 1;
		$sleepcount++;
	}

	if ($sleepcount >= $timeout) 
	{
		&error('Time Out - Try Again Later');
	}

	return 1;
}

# if the lock file doesn't exist, then create it
# if it does exist, check to see if we already own it
# if it exists, but we don't own it, then we fail
sub trylock
{
	if (-e "$lockfile")
	{
		my $found = 0;
		open(LOCKFILE, "$lockfile") || &error('Cannot open lock file for read');
		while(<LOCKFILE>)
		{
			if (/$$/)
			{
				return 1;
			}
		}
		close(LOCKFILE);
		return 0;
	}
	
	open(LOCKFILE, ">$lockfile") || &error('Cannot open lock file for Read/Write');
	print LOCKFILE "$$\n";
	close(LOCKFILE);
}

sub unlock
{
	if (-e "$lockfile")
	{
		my $found = 0;
		open(LOCKFILE, "$lockfile") || &error('Cannot open lock file for read');
		while(<LOCKFILE>)
		{
			if (/$$/)
			{
				$found = 1;
				break;
			}
		}
		close(LOCKFILE);
		
		$found || &error("Somebody else owns the lock.");
		&force_unlock();	
	}
}

sub force_unlock
{
	if (-e "$lockfile")
	{
		unlink($lockfile) || &error ("Failed to remove lock file");
	}
}
