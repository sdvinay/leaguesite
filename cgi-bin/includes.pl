#!$$perl_command$$

# $Revision: 1.7 $
# $Date: 2003/02/27 03:31:12 $

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
$releasehtml = "$genhtml_dir/released.html";
$faclaimhtml = "$genhtml_dir/claims.html";
$teamsurl    = "$genhtml_url/teams.html";
$htpasswdfile = "$$_data_loc$$/.htpasswd";

$auctstaturl = $genhtml_url . "/auction.html";
$availurl	 = $genhtml_url . "/available.html";
$bidurl      = $statichtml_url . "/bidpage.php";

require $rlfile;

$timeout = 4;
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
sub error {
   $error = $_[0];

   print "Content-type: text/html\n\n";
   print "<html><head><title>$$league_name$$</title></head>\n";
   print "<body><center><h1>$$league_name$$</h1></center>\n";
   print "<h2>Error:</h2><br>\n";
   print "$error\n";

	foreach $key (keys(%ENV))
	{
		print "$key => $ENV{$key} <br> \n";
	}
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
sub waste {
   print "Content-type: text/html\n\n";
   print "<html><head><title>Waste</title></head>\n";
   print "<body><center><h1>You Are Wasting My Time!!!</h1></center>\n";
   print "</center><hr><p>\n";
   print "\$command = \"$command\"";
   print "</body></html>\n";
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

