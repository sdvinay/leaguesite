#!$$perl_command$$
##############################################################################
# Bidprocess.pl
# 1. Verify Bids are legal
# 2. Post Bids
# Copyright 1997 Gregory A Greenman
# $Revision: 1.5 $
# $Date: 2003-02-25 23:34:41-08 $
##############################################################################
use File::Copy;

# Define Variables

require "includes.pl";

###########################################################################

&parse_form || &waste;
$command = "$FORM{'action'}";
$teamnum = $FORM{"teamnum"};
$password = $FORM{"password"};

if ($command eq "verify") {	&verify; }
elsif ($command eq "submit") { &submit; }
else { &waste; }


###########################################################################
sub verify {
	$league{'canbid'} || &error("Sorry, no Bids allowed at this time.");

	&lock;
	&tmchk;
	&bidchk;
	
	&printhtmlheader("Bid Verification");
	print "<h3>$teamnum $team</h3>\n";
	print "<h4>$man</h4><br>\n";
	
	print "<form method=POST action=\"$cgi_url/bidprocess.pl\">\n";
	print "<input type=hidden name=\"action\" value=\"submit\">\n";
	print "<input type=hidden name=\"teamnum\" value=\"$teamnum\">\n";
	print "<input type=hidden name=\"password\" value=\"$password\">\n";
	
	print "You made the following bids:<br>\n";
	print "<table border=2>\n";
	print "<tr><th>#</th><th>Name</th><th>Your Bid</th><th>Previous Bid</th></tr>\n";
	
	$bidtot = $cashbid;
	$bidnum = $numbid;
	$unbid = 0;
	$i = 0;

	foreach $player (@playarray) 
	{
		($playnum, $bid, $playname, $pstatus, $pteam, $psalary, $errmsg) = split(/:/, $player);
		print "<tr><td>$playnum</td><td>$playname</td><td align=right>$bid</td><td align=right>$psalary</td><td>$errmsg</td></tr>\n";
		
		print "<input type=hidden name=\"play$i\" value=\"$player\">\n";
		
		$bidtot += $bid;
		
		if ($pteam eq $teamnum) 
		{
			$unbid -= $psalary;
		}
		else 
		{
			$bidnum++;
		}
		
		$i++;
	}

	$bidtot += $unbid;
	$bavail = $league{'salarycap'} - $cashspent - $cashbid;
	$aavail = $league{'salarycap'} - $cashspent - $bidtot;
	
	print "</table><br>\n";
	
	print "<table border=2>\n";
	print "<tr><th></th><th>Before</th><th>After</th></tr>\n";
	print "<tr><td>Spent</td><td align=right>$cashspent</td><td align=right>$cashspent</td></tr>\n";
	print "<tr><td>Bid</td><td align=right>$cashbid</td><td align=right>$bidtot</td></tr>\n";
	print "<tr><td>Available</td><td align=right>$bavail</td><td align=right>$aavail</td></tr>\n";
	print "</table><br>\n";

	if ($playcnt eq 0) 
	{
		print "Uh...do you know what you're doing? You don't seem to have bid on anyone.<br>\n";
		print "I mean, What's the point?<br><br>\n";
		$error += 1;
	}
	if ($aavail < 0) 
	{
		print "Hey, did you forget about the salary cap?<br>\n";
		print "Sorry...no can do on those bids.<br><br>\n";
		$error += 1;
	}
	if ($bidnum + $numown > $league{'maxroster'}) 
	{
		print "Hey, did you forget about the roster cap?<br>\n";
		print "Sorry...no can do on those bids.<br><br>\n";
		$error += 1;
	}
	if ($error) 
	{
		print "Your bids have some serious problems.<br>\n";
		print "Click on your browser's \"Back\" button to fix your bids and then reverify them.<br>\n";
	}
	else 
	{
		print "Good job, your bids are legal.<br><br>\n";
		print "<input type=submit value=\"Submit Bids\">\n";
	}

	print "</form></center>\n";
	&printhtmlfooter;
	
	&unlock;
}



###########################################################################
sub submit {
	&lock();

	&tmchk;
	&bidchk;
	&bidfile;
	&updtstat;
	
	&unlock();
	
	require "$cgi_dir/update2.pl";
	print "Location: $availurl\n\n";
}




###########################################################################
sub tmchk 
{
	open(TEAMFILE,"$team_file") || &error('Could Not Open Team File for Reading');
	@tlines = <TEAMFILE>;
	close(TEAMFILE);
	
	my $found = 0;
	
	tloop:foreach $tlines_line (@tlines) 
	{
		($tnum,$passwd,$team,$man,$email,$stadium,$numown,$numbid,$cashspent,$cashbid) = split(/:/,$tlines_line);
		
		if ($tnum eq $teamnum) 
		{
			if ($password ne $passwd)
			{
				&error("The password entered is not correct for the team number entered.");
			}
			$found = 1;
			last tloop;
		}
	}
	$found || &error("That team number doesn't seem to exist.");
}


###########################################################################
sub bidchk {
   $error = 0;

   open(STATFILE,"$stat_file") || &error('Could Not Open Stat File for Reading');
   @slines = <STATFILE>;
   close(STATFILE);

	my $i = 0;
	foreach $key (keys(%FORM))
	{
		if (($key =~ /^bid(\d+)/ && $FORM{$key} && ($1 > $kMinPlayerNum)) ||
			($key =~ /qbid(\d+)/ && $FORM{$key} eq "QuickBid" && !$FORM{"bid$1"}))
		{
			$p = join(":", $1, $FORM{$key});
			$playarray[$i] = $p;
			$i++;
		}
		if (($key =~ /play(\d+)/ && $FORM{$key}))
		{
			$p = join(":", $FORM{$key}, $FORM{"bid$1"});
			$playarray[$i] = $p;
			$i++;
		}
	}

	@playarray = sort(@playarray);
	$playcnt = @playarray;
	if ($playcnt <= 0) { return; }
	
	$error = 0;
	for ($i = 0; $i < $playcnt; $i++) 
	{
		($parray[$i], $barray[$i]) = split(/:/, $playarray[$i]);
		$barray[$i] =~ s/^\s*(.*?)\s*$/$1/;
		$barray[$i] =~ s/^0+//;
		$barray[$i] =~ s/\.[0-9]*$//;
	}

	$i = 0;
	$prevplay = "";

	sloop: foreach $slines_line (@slines) 
	{
		($playnum, $playname, $pstatus, $pteam, $psalary) = split(/:/, $slines_line);
		chomp($psalary);

		while ($playnum gt $parray[$i]) 
		{
            $errmsg = "Player Not Found";
            $error += 1;

            @playarray[$i] = join(":", $parray[$i], $barray[$i], "", "", "", "", $errmsg);
            $prevplay = $parray[$i];
            $i++;

            last sloop if ($i eq $playcnt);
		}

		while ($playnum eq $parray[$i]) 
		{
			$errmsg = "";
			
			if ($barray[$i] eq "QuickBid")
			{
				$barray[$i] = $psalary+1;
			}
			if ($barray[$i] <= $psalary) 
			{
				$errmsg = "Bid Not High Enough";
				$error += 1;
			}
			if ($parray[$i] eq $prevplay) 
			{
				$errmsg = "Player Already Bid On";
				$error += 1;
			}
			if ($pstatus eq "5") 
			{
				$errmsg = "Player Already Sold";
				$error += 1;
			}
			if (($pstatus eq "0") && !($league{'cannewplyr'})) 
			{
				$errmsg = "New Players May No Longer Be Bid On";
				$error += 1;
			}

			@playarray[$i] = join(":", $parray[$i], $barray[$i], $playname, $pstatus, $pteam, $psalary, $errmsg);
			$prevplay = $parray[$i];
			$i++;
			
			last sloop if ($i eq $playcnt);
		} # end while ($playnum eq $parray[$i]) 
	} # end sloop

	while ($i lt $playcnt) 
	{
		$errmsg = "Player Not Found";
		$error += 1;
		
		@playarray[$i] = join(":", $parray[$i], $barray[$i], "", "", "", "", $errmsg);
		$i++;
	}
}



###########################################################################
sub gettime {
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

   $mnth = $mon + 1;

   if ($sec < 10) {
      $sec = "0$sec";
   }
   if ($min < 10) {
      $min = "0$min";
   }
   if ($hour < 10) {
      $hour = "0$hour";
   }
   if ($mon < 10) {
      $mnth = "0$mnth";
   }
   if ($mday < 10) {
      $mday = "0$mday";
   }

   $month = $mon + 1;

   @months = ("January","February","March","April","May","June","July","August","September","October","November","December");

   $intdate = join(":", $year, $mnth, $mday, $hour, $min, $sec);
   $date = "$hour\:$min\:$sec $mnth/$mday/$year";
   chop($date) if ($date =~ /\n$/);

   $year = $year + 1900;

   return "$months[$mon] $mday, $year at $hour\:$min\:$sec";
}



###########################################################################
sub bidfile {
	open(BFILE, ">>$bfile") || &error('Cannot Open Bid File for Append');
	
	my $long_date = &gettime();
	foreach $player (@playarray) 
	{
		($playnum, $bid, $playname, $pstatus, $pteam, $psalary, $errmsg) = split(/:/, $player);
		
		$xteam = "$team                  ";
		$xteam = substr($xteam, 0, 18);
		
		print BFILE "$long_date\t$teamnum $xteam\t$playnum\t$playname\t$bid\t$psalary\t$errmsg\n";
	}
	
	close(BFILE);
}



###########################################################################
sub updtstat {
   copy("$stat_file", "$stat_bak");

   open(STATFILE,"$stat_file") || &error('Cannot Open Status File for Reading');
   @slines = <STATFILE>;
   close(STATFILE);

   open(STATFILE,">$stat_file") || &error('Cannot Open Status File for Read/Write');

   $i = 0;
   $playcnt = @playarray;

   foreach $player (@playarray) {
      ($parray[$i], $barray[$i], $pname, $pstat, $pteam, $psal, $errarray[$i]) = split(/:/, $player);

      $i++;
   }

   $i = 0;
   $o = 1;

   sloop: foreach $sline (@slines) {
      ($playnum, $playname, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec) = split(/:/, $sline);

      chomp($bsec);

      while ($errarray[$i] ne "") {
         $i++;
#         last sloop if ($i eq $playcnt);
      }

      if ($playnum eq $parray[$i]) {
         if ("01" =~ /$pstatus/) {
            $pstatus = "1";
         }
         else {
            $pstatus = "2";
         }

         $pline = join(":", $playnum, $playname, $pstatus, $teamnum, $barray[$i], $intdate);

         if (("123" =~ /$pstatus/) && ($teamnum ne $pteam)) {
            $outbid[$o] = join(":", $pteam, $psalary, $playnum, $playname);
            $o++;
         }

         print STATFILE "$pline\n";

         $i++;
#         last sloop if ($i eq $playcnt);
      }
      else {
         $pline = join(":", $playnum, $playname, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec);
         print STATFILE "$pline\n";
      }
   }

   close(STATFILE);

   @outbid = sort(@outbid);
}
