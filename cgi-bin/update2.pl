#!$$perl_command$$
##############################################################################
# Update.pl
# Copyright 1997 Gregory A Greenman
# $Revision: 1.11 $
# $Date: 2003-03-05 15:24:10-08 $
##############################################################################

require "includes.pl";

###########################################################################
@status_labels = ("Available", "New Player", "Do I Hear...", 
	"Going Once", "Going, Going...", "Sold","Sold","7","8","Penalty");

###########################################################################

return &updateall;

###########################################################################
sub updateall {
   if (&chktemp()) {
      &updtteams;
      &buildstat;
      &buildavail;
      &buildtrades;
      &buildrelease;
      &buildclaims;
      &updtteamhtml;
      &updtteampgs;

      unlink "$atempfile";
   }
   else {
#      &error('???');
   }
}

###########################################################################
sub chktemp 
{
   $scount = 0;

   while (((-e "$btempfile") || (-e "$atempfile")) && ($scount < $timeout)) {
      sleep 2;
      $scount++;
   }

   if ($scount >= $timeout) {
      &error('Time Out - Try Again Later');
   }

   open(WAITFILE, ">$atempfile") || &error('Cannot open Wait File for Read/Write');
   print WAITFILE "$year:$mnth:$mday:$hour:$min:$sec\n";
   close(WAITFILE);

   return 1;
}




###########################################################################
sub updtteams {
	open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
	@slines = <STATFILE>;
	close(STATFILE);

	foreach $statline (@slines) 
	{
		($pnum, $pname, $pstat, $pteam, $psalary) = split(/:/, $statline);
		if ($pteam ne "999") 
		{
			if ($pstat == 5 || $pstat == 6)
			{
				$tplown[$pteam]++;
				$tspent[$pteam] += $psalary;
			}
			elsif ($pstat == 9) 
			{
				$tspent[$pteam] += $psalary;
			}
			else 
			{
				$tplbid[$pteam]++;
				$tbid[$pteam] += $psalary;
			}
		}
	}

	open(TEAMFILE, "$team_file") || &error('Could not open team file for reading');
	@tlines = <TEAMFILE>;
	close(TEAMFILE);

	open(TEAMFILE, ">$team_file") || &error('Could not open team file for read/write');
	
	foreach $teamline (@tlines) 
	{
		trim($teamline);
		($teamnum, $passwd, $teamname, $towner, $temail, $tstad, $tplown, $tplbid, $tspent, $tbid) = split(/:/, $teamline);
		$tline = join(":", $teamnum, $passwd, $teamname, $towner, $temail,$tstad,
			int($tplown[$teamnum]), int($tplbid[$teamnum]), int($tspent[$teamnum]), int($tbid[$teamnum]));
		print TEAMFILE "$tline\n";		
	}

	close(TEAMFILE);
}


###########################################################################
sub buildstat {
   open(TEAMFILE, "$team_file") || &error('Could not open team file for reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   foreach $teamline (@tlines) {
      ($teamnum, $passwd, $teamname, $towner, $temail, $tstad, $tplown, $tplbid, $tspent, $tbid) = split(/:/, $teamline);
      $team{$teamnum} = $teamname;
   }

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

	foreach $sline (@slines) 
	{
		#intentionally retain the newline, since we're joining the fields back together
		($playnum, $playname, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec) = split(/:/, $sline);
		$dstatus = ($pstatus == 6) ? 5 : $pstatus;	
		push @alines, join(":", $playname, $playnum, $dstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec);
	}

	@alines = sort(@alines);


   open(STATHTML, ">$stathtml") || &error('Could not open stat html file for read/write');

   $oldfh = select(STATHTML);
   &printhtmlheader("Player Status", 0, 0);
   select($oldfh);

   print STATHTML "<table border=2>\n";
   if ($league{'canbid'})
   {
       print STATHTML "<tr><th>#</th><th>Player</th><th>Status</th><th colspan=2>Team</th><th>\$</th><th>Bid</th></tr>";
   }
   else {
       print STATHTML "<tr><th>#</th><th>Player</th><th>Status</th><th colspan=2>Team</th><th>\$</th></tr>";
   }

   foreach $player (@alines) {
      ($playname, $playnum, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec) = split(/:/, $player);

      if ($pteam == "999") {
         $pteam = "";
         $pteamname = "";
      }
      else {
         $pteamname = $team{$pteam};
      }

      print STATHTML "<tr><td>$playnum</td><td>$playname</td>";

      print STATHTML "<td align=center>$status_labels[$pstatus]</td>";
      print STATHTML "<td>$pteam</td><td>$pteamname</td><td align=right>$psalary</td>";
      if ($league{'canbid'}) {
          if ($pstatus < 5) {
              my $bidamt = $psalary+1;
              print STATHTML "<td><a href=$bidurl?pnum=$playnum&bid=$bidamt>Bid</a></td>";
          } else {
              print STATHTML "<td></td>";
          }
      }
      print STATHTML "</tr>\n";
   }

   print STATHTML "</table></center>\n";

   $oldfh = select(STATHTML);

   &prnt_pfooter;

   select($oldfh);

   close(STATHTML);
}


###########################################################################
sub buildavail {
	open(STATFILE,"$stat_file") || &error('Could not open stat file for reading');
	@slines = <STATFILE>;
	close(STATFILE);

	foreach $sline (@slines) 
	{
		#intentionally retain the newline, since we're joining the fields back together
		($playnum, $playname, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec) = split(/:/, trim($sline) );
		$dstatus = ($pstatus == 6) ? 5 : $pstatus;
		push @alines, join(":", $dstatus, $playname, $playnum, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec);
	}

	@alines = sort(@alines);

	open(AUCTHTML, ">$availhtml") || &error('Could not open Available html file for writing');
	$oldfh = select(AUCTHTML);
	
	&printhtmlheader("Available Players", 0);
	
	print "<div class=\"alert\">Note: the auctioneer runs at 7pm PST/10pm EST</div>\n";
	
	#links to jump to particular sections
	sub printinternallinks
	{
		if ($league{'canbid'})
		{
			print "<p>\n";
			#this list ought to agree with the order of sections printed, though it won't break anything if it's not
			foreach $section (1,2,3,4,0) 
			{
				print "<a href=#section$section>$status_labels[$section]</a>"
			}
			continue { print "&nbsp;|&nbsp;"; }
			print "</p>\n";
		}
	}
	
	sub printsection
	{
		my $x = $_[0];
		print "<a name=section$x></a>\n";
		&printinternallinks();
		print "<table border=2>\n";
		if ($x > 0) 
		{
			print "<tr><th colspan=8><font size= +2>$status_labels[$x]</font></th></tr>\n";
			print "<tr><th>#</th><th>Player</th><th colspan=2>Team</th><th>\$</th><th>Bid</th><th>Quick Bid</th><th>Last Bid</th></tr>\n";
		}
		else 
		{
			print "<tr><th colspan=4><font size= +2>$status_labels[$x]</font></th></tr>\n";
			print "<tr><th>#</th><th>Player</th><th>Bid</th><th>Quick Bid</th></tr>\n";
		}
		playerloop: foreach $pline (@alines)
		{
			($xstatus, $playname, $playnum, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec) = split(/:/, $pline);

			#we know the lines are sorted by status, so if we're done, no need to go through the rest
			if ($xstatus < $x) { next playerloop; }
			if ($xstatus > $x) { last playerloop; } 
			
			if ($x > "0") 
			{
				$pteamname = $team{$pteam};
				if ($byr < 1900) { $byr += 1900; }
				$bidtime = "$bmon/$bday/$byr - $bhr:$bmin:$bsec";
			}
			
			print "<tr>";
			print "<td>$playnum</td><td><a href=$bidhistoryurl?player=$playnum>$playname</a></td>" unless ($x == 0);
			print "<td>$playnum</td><td>$playname</td>" if ($x == 0);
			print "<td>$pteam</td><td>$pteamname</td>" unless ($x == 0);
			print "<td align=right>$psalary</td>" unless ($x == 0);
			print "<td><input type=text size=4 name=bid$playnum></td><td><input type=submit value=\"QuickBid\" name=qbid$playnum></td>";
			print "<td>$bidtime</td>" unless ($x == 0);
			print "</tr>\n";
			
			
		} # end playerloop
		print "</table>\n";
	} # end sub printsection
	
	if ($league{'canbid'})
	{
		print "You will be prompted for team # and password after hitting \"Confirm\" or \"Quick Bid\".";
		print "<form name=bidding action=\"$$_restricted_url$$/redirect_bidprocess.php\" method=post>\n";
		print "<input type=\"hidden\" name=\"action\" value=\"verify\">\n";
		print "<input type=submit value=\"Confirm\"> <input type=reset value=\"Clear All Bids\"><br>\n";
	}
	if ($league{'canbid'})
	{
		&printsection(1);
		&printsection(2);
		&printsection(3);
		&printsection(4);
		&printsection(0);
	}
	else
	{
		&printsection(0);
	}

	print "</table></center>\n";
	&prnt_pfooter;
	select($oldfh);
	close(AUCTHTML);
}



###########################################################################
sub buildtrades {
   open(TEAMFILE, "$team_file") || &error('Could not open team file for reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   foreach $teamline (@tlines) {
      ($teamnum, $passwd, $teamname) = split(/:/, $teamline);

      $team{$teamnum} = $teamname;
   }

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

   foreach $statline (@slines) {
      ($pnum, $pname, $pstatus, $pteam, $psalary) = split(/:/, $statline);

      $statname{$pnum} = $pname;
      $statslry{$pnum} = $psalary;
   }

   open(TRDFILE, "$tradefile") || &error('Could not open trade file for reading');
   @trdlines = <TRDFILE>;
   close(TRDFILE);

   open(TRDHTML, ">$tradehtml") || &error('Could not open trade html file for writing');

   select(TRDHTML);

   &printhtmlheader("Trades", 0);
   print "<table border=2>\n";

   $prevseries = "xx";

   for($i=@trdlines - 1; $i >= 0; $i--) {
      ($tseries, $t0num, $t0players, $t1num, $t1players) = split(/:/, $trdlines[$i]);

      @t0players = split(/,/, $t0players);
      @t1players = split(/,/, $t1players);

      foreach $tplayer (@t1players) {
         chomp($tplayer);
      }

      if (@t1players > @t0players) {
         $max = @t1players;
      }
      else {
         $max = @t0players;
      }

      if ($tseries ne $prevseries) {
         print "<tr><th colspan=8><font size= +2>Series #$tseries</font></th></tr>\n";
         $prevseries = $tseries;
      }

      print "<tr><th colspan=4>$t0num $team{$t0num}</th><th colspan=4>$t1num $team{$t1num}</th></tr>\n";

      for($x=1; $x <= $max; $x++) {
         if ($x <= @t0players) {
            print "<tr><td>$x</td><td>$t0players[$x-1]</td><td>$statname{$t0players[$x-1]}</td><td align=right>$statslry{$t0players[$x-1]}</td>";
         }
         else {
            print "<tr><td></td><td></td><td></td><td></td>";
         }

         if ($x <= @t1players) {
            print "<td>$x</td><td>$t1players[$x-1]</td><td>$statname{$t1players[$x-1]}</td><td align=right>$statslry{$t1players[$x-1]}</td></tr>\n";
         }
         else {
            print "<td><td></td><td></td><td></td></tr>\n";
         }
      }

      print "<tr></tr>\n";
   }

   print "</table></center>\n";

   &prnt_pfooter;

   select(STDOUT);

   close(TRDHTML);
}



###########################################################################
sub buildrelease {
   open(TEAMFILE, "$team_file") || &error('Could not open team file for reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   foreach $teamline (@tlines) {
      ($teamnum, $passwd, $teamname) = split(/:/, $teamline);

      $team{$teamnum} = $teamname;
   }

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

   foreach $statline (@slines) {
      ($pnum, $pname, $pstatus, $pteam, $psalary) = split(/:/, $statline);

      $statname{$pnum} = $pname;
      $statslry{$pnum} = $psalary;
   }

   open(RELFILE, "$relfile") || &error('Could not open release file for reading');
   @rellines = <RELFILE>;
   close(RELFILE);

   open(RELHTML, ">$releasehtml") || &error('Could not open release html file for writing');

   select(RELHTML);

   &printhtmlheader("Players Released", 0);
   print "<table border=2>\n";

   $prevseries = "xx";

   for($i=@rellines - 1; $i >= 0; $i--) {
      ($tseries, $tnum, $tplayers) = split(/:/, $rellines[$i]);

      chomp($tplayers);

      if ($tseries ne $prevseries) {
         print "<tr><th colspan=3><font size= +2>Series #$tseries</font></th></tr>\n";
         $prevseries = $tseries;
      }

      print "<tr><td>$tnum $team{$tnum}</td><td>$tplayers</td><td>$statname{$tplayers}</td>";

      print "<tr></tr>\n";
   }

   print "</table></center>\n";

   &prnt_pfooter;

   select(STDOUT);

   close(RELHTML);
}



###########################################################################
sub buildclaims {
   open(TEAMFILE, "$team_file") || &error('Could not open team file for reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   foreach $teamline (@tlines) {
      ($teamnum, $passwd, $teamname) = split(/:/, $teamline);

      $team{$teamnum} = $teamname;
   }

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

   foreach $statline (@slines) {
      ($pnum, $pname, $pstatus, $pteam, $psalary) = split(/:/, $statline);

      $statname{$pnum} = $pname;
   }

   open(FACLAIM, "$faclaim") || &error('Could not open Free Agent Claim file for reading');
   @falines = <FACLAIM>;
   close(FACLAIM);

   open(FACLAIM, ">$faclaimhtml") || &error('Could not open Free Agent Claim html file for writing');

   select(FACLAIM);

   &printhtmlheader("Free Agent Claims", 0);
   print "<table border=2>\n";

   $prevseries = "xx";

   for($i=@falines - 1; $i >= 0; $i--) {
      ($tseries, $teamnum, $tplayer, $tsal) = split(/:/, $falines[$i]);

      if ($tseries ne $prevseries) {
         print "<tr><th colspan=3><font size= +2>Series #$tseries</font></th></tr>\n";
         $prevseries = $tseries;
      }

      print "<tr><td>$teamnum $team{$teamnum}</td><td>$tplayer $statname{$tplayer}</td><td align=right>$tsal</td></tr>\n";
   }

   print "</table></center>\n";
   &prnt_pfooter;
   select(STDOUT);

   close(FACLAIM);
}



###########################################################################
sub updtteamhtml {
   open(TEAMFILE,"$team_file") || &error('Cannot Open Team File for Reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   open(TEAMHTML,">$teamhtml") || &error('Cannot Open Team HTML File for Read/Write');

   foreach $team (@tlines) {
       chomp $team;
       ($teamnum, $passwd, $teamname, $manager, $email, $stad, $tplown, $tplbid, $cashspent, $cashbid) = split(/:/, $team);

       push  @teamnums, $teamnum;
       $passwd[$teamnum] = $paswd;
       $teamname[$teamnum] = $teamname;
       $manager[$teamnum] = $manager;
       $mail[$teamnum] = $email;
       $stad[$teamnum] = $stad;
       $tplown[$teamnum] = $tplown;
       $tplbid[$teamnum] = $tplbid;
       $cashspent[$teamnum] = $cashspent;
       $cashbid[$teamnum] = $cashbid;
   }

   open(DIVFILE, "$div_file") || &error('Cannot open div file for reading');
   @divlines = <DIVFILE>;
   close(DIVFILE);
   for ($i = 0; $i < 6; $i++)
   {
       trim $divlines[$i];
       $div[$i]  = [ split(",", $divlines[$i]) ];
   }

	   
   for ($i = 0; $i < 6; $i++)
   {
       my @tempdivmail;
       for ($j = 0; $j < 4; $j++)
       {
	   push @tempdivmail, $mail[$div[$i][$j]];
	   $divmail[$i] = join(",", @tempdivmail);
       }
   }

   $nlmail = join(",", @divmail[0..2]);
   $almail = join(",", @divmail[3..5]);
   $leaguemail = "$nlmail,$almail";

   $leaguemail =~ s/,,/,/g;
   $nlmail =~ s/,,/,/g;
   $lamail =~ s/,,/,/g;
   $divmail[0] =~ s/,,/,/g;
   $divmail[1] =~ s/,,/,/g;
   $divmail[2] =~ s/,,/,/g;
   $divmail[3] =~ s/,,/,/g;
   $divmail[4] =~ s/,,/,/g;
   $divmail[5] =~ s/,,/,/g;

   $leaguemail =~ s/,$//;
   $nlmail =~ s/,$//;
   $lamail =~ s/,$//;
   $divmail[0] =~ s/,$//;
   $divmail[1] =~ s/,$//;
   $divmail[2] =~ s/,$//;
   $divmail[3] =~ s/,$//;
   $divmail[4] =~ s/,$//;
   $divmail[5] =~ s/,$//;

   $oldfh = select(TEAMHTML);
   &printhtmlheader("Team Page", 0);
   select($oldfh);

   print TEAMHTML "<table border=2>\n";

   $prevy = -1;

   @division = ("National League - West", "National League - Central", "National League - East", "American League - West", "American League - Central", "American League - East");

   for ($div=0; $div < 6; $div++) {
       if ($div == 0) {
	   print TEAMHTML "<tr><th colspan=8 height=50><a href=\"mailto:$nlmail\"><big +2>National League</big></a></th></tr>\n";
         }
       elsif ($div == 3) {
	   print TEAMHTML "<tr><th colspan=8 height=50><a href=\"mailto:$almail\"><big +2>American League</big></a></th></tr>\n";
       }

       print TEAMHTML "<tr><th colspan=8><a href=\"mailto:$divmail[$div]\">$division[$div]</a></th></tr>\n";
       print TEAMHTML "<tr><th>#</th><th>Team Name</th><th>Stadium</th><th>Owner</th><th>#</th><th>Spent</th><th>Bid</th><th>Remaining</th></tr>\n";

       for ($i = 0; $i < 4; $i++)
       {
	   $teamnum = $div[$div][$i];
	   my $cashavail = $league{'salarycap'} - $cashspent[$teamnum] - $cashbid[$teamnum];	
	   print TEAMHTML "<tr><td>$teamnum</td><td><a href=\"$genhtml_url/team$teamnum.html\">$teamname[$teamnum]</a></td><td>$stad[$teamnum]</td><td><a href=\"mailto:$mail[$teamnum]\">$manager[$teamnum]</a></td><td align=right>$tplown[$teamnum]</td><td align=right>$cashspent[$teamnum]</td><td align=right>$cashbid[$teamnum]</td><td align=right>$cashavail</td></tr>\n";
       }
   }

   print TEAMHTML "</table></center>\n";

   select(TEAMHTML);
   &prnt_pfooter;
   select(STDOUT);
   close(TEAMHTML);
}


###########################################################################
sub updtteampgs {

   open(TEAMFILE, "$team_file") || &error('Could not open team file for reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

	foreach $statline (@slines) 
	{
		#intentionally retain the newline, since we're joining the fields back together
		($pnum, $pname, $pstat, $pteam) = split(/:/, $statline);

		if ($pteam ne "999") 
		{
			$dstat = ((($pstat == 6) || ($pstat == 9)) ? 1 : (6-$pstat));
			$mline = join(":", $pteam, $dstat, $pname, $statline);
			push @player, $mline;
		}
	}

	@players = sort(@players);

   $i = 0;
   $x = 0;

   foreach $teamline (@tlines) {
      ($teamnum, $passwd, $teamname, $towner, $temail, $tstad, $tplown, $tplbid, $tspent, $tbid) = split(/:/, $teamline);
      chomp($tbid);

      $tavail = $league{'salarycap'} - $tspent - $tbid;

      open(INDTEAM, ">$teamdir/team$teamnum.html") || &error('Could not open individual team html file for writing');

      $oldfh = select(INDTEAM);
      &printhtmlheader("$teamnum $teamname", 0);
      select($oldfh);

      print INDTEAM "<h4><a href=\"mailto:$temail\">$towner</a></h4>\n";
      print INDTEAM "<hr><p>\n";

      if    (-e "$teamdir/$teamnum.gif") {
         print INDTEAM "<img src=\"$teamnum.gif\"><p>\n";
      }
      elsif (-e "$teamdir/$teamnum.jpg") {
         print INDTEAM "<img src=\"$teamnum.jpg\"><p>\n";
      }

      print INDTEAM "<table border=2>\n";
      print INDTEAM "<tr><th colspan=2><font size= +2>Cash</font></th></tr>\n";
      print INDTEAM "<tr><td>Spent</td><td align=right>$tspent</td></tr>\n";
      print INDTEAM "<tr><td>Bid</td><td align=right>$tbid</td></tr>\n";
      print INDTEAM "<tr><td>Available</td><td align=right>$tavail</td></tr>\n";
      print INDTEAM "</table><br>\n";

      print INDTEAM "<table border=2>\n";
      print INDTEAM "<tr><th colspan=8><font size= +2>Players Owned</font></th></tr>\n";
      print INDTEAM "<tr><th></th><th>#</th><th>Player</th>";
      print INDTEAM "<th>Salary</th><th>Status</th></tr>\n";

      ($xteam, $dstat, $xname, $pnum, $pname, $pstat, $pteam, $psalary) = split(/:/, $players[$i]);

      $n = 1;

      while (($teamnum eq $pteam) && ($dstat eq "1")) {
         print INDTEAM "<tr><td align=right>$n</td><td>$pnum</td><td>$pname</td>";
         print INDTEAM "<td align=right>$psalary</td><td>$status_labels[$pstat]</td></tr>\n";

         $i++;
         $n++;
         ($xteam, $dstat, $xname, $pnum, $pname, $pstat, $pteam, $psalary) = split(/:/, $players[$i]);
      }

      if ($league{'canbid'}) {
         print INDTEAM "<tr><th colspan=8><font size= +2>Current High Bids</font></th></tr>\n";
         print INDTEAM "<tr><th></th><th>#</th><th>Player</th><th>Salary</th><th>Status</th></tr>\n";

         while (($teamnum eq $pteam) && ("1234" =~ /$pstat/)) {
            print INDTEAM "<tr><td align=right>$n</td><td>$pnum</td><td>$pname</td>";
            print INDTEAM "<td align=right>$psalary</td><td>$status_labels[$pstat]</td></tr>\n";

            $i++;
            $n++;
            ($xteam, $dstat, $xname, $pnum, $pname, $pstat, $pteam, $psalary) = split(/:/, $players[$i]);
         }
      }

      print INDTEAM "</table></center>\n";

      select(INDTEAM);
      &prnt_pfooter;
      select(STDOUT);

      close(INDTEAM);
   }
}

