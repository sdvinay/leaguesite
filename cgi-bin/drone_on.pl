#!$$perl_command$$
##############################################################################
# drone_on.pl
# Copyright 1997 Gregory A Greenman
# $Revision: 1.5 $
# $Date: 2003-03-05 17:41:29-08 $
##############################################################################
use File::Copy;

require "includes.pl";

###########################################################################

&parse_form || &waste;

# first verify the password
$passwd = "$FORM{'DronePassword'}";
($passwd eq $league{'dronepw'}) || &error("Incorrect drone password. Go back and try again.");

# dispatch
&lock();
$command = "$FORM{'action'}";
if ($command eq "droneon") { &droneon; }
elsif ($command eq "droneprocess") { &droneprocess; }
else { &waste(); }
&unlock();
return;


###########################################################################
sub droneon 
{
	&getteaminfo;
	&getplyrinfo;
	&processfagents;
	$numties ? &createtiebreakscreen() : &createscreen();
}


###########################################################################
sub droneprocess {
   require $rlfile;

   copy("$fafile", "$data_dir/fagent$league{'series'}.txt");

   $b = 0;
   $bname = "bid$b";

   while ($FORM{$bname}) {
      $bids[$b] = $FORM{$bname};

      $b++;
      $bname = "bid$b";
   }

#   @bids = sort(@bids);
   $i = 0;

   foreach $bid (@bids) {
      ($player, $teamnum, $salary, $sechigh, $releases) = split(/~/, $bid);

      if ($salary > $sechigh) {
         $salary = $sechigh + 1;
      }

      $pstat[$i] = join(":", $player, $teamnum, $salary, "5", 0, 0, 0);
      $i++;

      ($plyr[0], $plyr[1], $plyr[2], $plyr[3], $plyr[4], $plyr[5], $plyr[6], $plyr[7]) = split(/,/, $releases);

      for ($x = 0; $x < 8; $x++) {
         if ($plyr[$x]) {
            $pstat[$i] = join(":", $plyr[$x], "999", 0, "0", $teamnum);
            $i++;
         }
      }
   }

   @pstat = sort(@pstat);
   $i = 0;

   foreach $pstat (@pstat) {
      ($parray[$i], $pteam[$i], $psal[$i], $pstatus[$i], $formerteam[$i]) = split(/:/, $pstat);
      $i++;
   }

   $i = 0;

   open(STATFILE, "$stat_file") || &error('Could Not Open Stat File for Reading');
   @slines = <STATFILE>;
   close (STATFILE);

   open(STATFILE, ">$stat_file") || &error('Could Not Open Stat File for Read/Write');

   foreach $sline (@slines) {
      ($playnum, $playname, $pstatus, $pteam, $psalary, $dy, $dm, $dd, $th, $tm, $ts) = split(/:/, $sline);

      chomp($ts);

      if ($playnum eq $parray[$i]) {
         print STATFILE "$playnum:$playname:$pstatus[$i]:$pteam[$i]:$psal[$i]:$dy:$dm:$dd:$th:$tm:$ts\n";

         $i++;
      }
      else {
         print STATFILE "$sline";
      }
   }

   close (STATFILE);

   $i = 0;

   open(RFILE, ">>$relfile") || &error('Could Not Open Release File for Read\Write');

   foreach $plyr (@parray) {
      if ($pstatus[$i] eq "0") {
         print RFILE "$league{'series'}:$formerteam[$i]:$parray[$i]\n";
      }

      $i++;
   }

   close (RFILE);

   $i = 0;

   open (FACLAIM, ">>$faclaim") || &error('Could Not Open Claim File for Read\Write');

   foreach $plyr (@parray) {
      if ($pstatus[$i] eq "5") {
         print FACLAIM "$league{'series'}:$pteam[$i]:$parray[$i]:$psal[$i]\n";
      }

      $i++;
   }

   close (FACLAIM);

   open (FAFILE, ">$fafile") || &error('Could Not Open Free Agent File for Read\Write');
   close (FAFILE);

   $league{'series'}  = $FORM{'SeriesNum'};
   $league{'duedate'} = $FORM{'Date'};
#   $league{'duetime'} = $FORM{'Time'};

   open(LEAGUEFILE,">$leaguefile") || &error('Cannot open league file for read/write');
   foreach $key (keys %league) {
      print LEAGUEFILE "$key~$league{$key}\n";
   }
   close(LEAGUEFILE);

   unlink "$dtempfile";

   require "$cgi_dir/update2.pl";

   print "Location: " . $php_url . "/setleaguefileurl.php\n\n";
}




###########################################################################
sub getteaminfo {
   open(TEAMFILE,"$team_file") || &error('Could Not Open Team File for Reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   $more = 0;

   tloop:foreach $tline (@tlines) {
      ($teamnum, $a, $teamname, $c, $d, $e, $numown, $f, $cashspent, $g) = split(/:/, $tline);

      $TNAME{$teamnum}    = $teamname;
      $NUMOWN{$teamnum}   = $numown;
      $CASH{$teamnum}     = $cashspent;
      $PRIORITY{$teamnum} = 0;

      $pteam = "P$teamnum";

      if ($FORM{$pteam}) {
         $PRIORITY{$teamnum} = 24 - $FORM{$pteam};
         $more = 1;
      }
   }
}




###########################################################################
sub getplyrinfo {
   open(STATFILE,"$stat_file") || &error('Could Not Open Team File for Reading');
   @slines = <STATFILE>;
   close(STATFILE);

   sloop:foreach $sline (@slines) {
      ($playnum, $a, $b, $teamnum, $salary) = split(/:/, $sline);

      $OWNER{$playnum}  = $teamnum;
      $SALARY{$playnum} = $salary;
   }
}





###########################################################################
sub processfagents {
   open(FAFILE, "$fafile");
   @flines = <FAFILE>;
   close(FAFILE);

   $x = 0;
   $f = 0;
   $numties = 0;

   @flines = sort(@flines);

   $maxf = scalar(@flines);

   $prevplay = "";

   foreach $fline (@flines) {
      ($a, $playnum, $time) = split(/:/, $fline);

      if ($playnum ne $prevplay) {
         $forders[$x] = "$time:$playnum";
         $x++;
      }

      $prevplay = $playnum;
   }

   @forders = sort(@forders);

   foreach $forder (@forders) {
      ($a, $procplayer) = split(/:/, $forder);
      $highbid = 0;
      $sechigh = 0;
      $highbidder = "";
      $highrels = "";
      $tires = 0;

      @plyr = ();

#      for ($z = 0; $z < 8; $z++) {
#         $plyr[$z] = "";
#      }

      for ($y = 0; $y < $maxf; $y++) {
         ($a, $playnum, $b, $teamnum, $bid, $releases) = split(/:/, $flines[$y]);

         chomp($releases);

         if ($playnum == $procplayer) {
            ($plyr[0], $plyr[1], $plyr[2], $plyr[3], $plyr[4], $plyr[5], $plyr[6], $plyr[7]) = split(/,/, $releases);

            $maxbid = $league{'salarycap'} - $CASH{$teamnum};

            $z = 0;

            foreach $p (@plyr) {
               if ($OWNER{$plyr[$z]} eq $teamnum) {
                  $maxbid += $SALARY{$plyr[$z]};
               }

               $z++;
            }

            if ($bid > $maxbid) {
               $bid = $maxbid;
            }

            if ($bid > $highbid) {
               if ($teamnum ne $highbidder) {
                  $sechigh = $highbid;
                  $highbidder = $teamnum;
               }

               $tiebidder = "";
               $highbid = $bid;
               $highrels = "$releases";
               $tires = 0;
            }
            elsif (($bid == $highbid) && ($PRIORITY{$teamnum} > $PRIORITY{$highbidder}) && ($bid > 0)) {
               $tiebidder = "$tiebidder|$teamnum";

               $sechigh = $highbid;
               $highbid = $bid;
               $highbidder = $teamnum;
               $highrels = "$releases";
               $tires = 0;
            }
            elsif (($bid == $highbid) && ($PRIORITY{$teamnum} == $PRIORITY{$highbidder}) && ($bid > 0) && ($teamnum ne $highbidder)) {
               $highbidder = "$highbidder|$teamnum";
               $highrels = "";
               $sechigh = $highbid - 1;
               $tires++;
            }
            elsif (($bid > $sechigh) && ($teamnum ne $highbidder)) {
               $sechigh = $bid;
            }
         }
      }

      if (($tires == 0) && ($highbid > 0)) {
         $CASH{$highbidder} += $sechigh;

         unless ($sechigh == $highbid) {
            $CASH{$highbidder}++;
         }

#         ($a, $releases) = split(/:/, $highrels);
         ($plyr[0], $plyr[1], $plyr[2], $plyr[3], $plyr[4], $plyr[5], $plyr[6], $plyr[7]) = split(/,/, $highrels);

         $highrels = "";
#         $rels = "";
         $x = 0;

         if ($CASH{$highbidder} > $league{$salarycap}) {
            while (($CASH{$highbidder} > $league{$salarycap}) && ($x < 8)) {
               $CASH{$highbidder} -= $SALARY{$plyr[$x]};
               $x++;
            }

            $x--;

            for ($x = $x; $x >= 0; $x--) {
               if ($CASH{$highbidder} + $SALARY{$plyr[$x]} > $league{'salarycap'}) {
                  $highrels = join(",", $highrels, $plyr[$x]);
               }
               else {
                  $CASH{$highbidder} += $SALARY{$plyr[$x]};
               }
            }
         }

         $highrels =~ s/^,//;

         $fa[$f] = "$procplayer~$highbidder~$highbid~$sechigh~$highrels";
         $f++;

         if ($tiebidders ne "") {
            $tieguys[$numties] = $highbidder;
            $numties++;
         }
      }
      elsif ($highbid > 0) {
         $tieguys[$numties] = $highbidder;
         $numties++;

         $fa[$f] = "$procplayer~$highbidder~$highbid~$sechigh~$highrels";
         $f++;
      }
   } #    foreach $forder (@forders)
}




###########################################################################
sub createtiebreakscreen {
	&printhtmlheader("File Drone Processing");
   print "<form method=POST action=\"$cgi_url/drone_on.pl\">\n";
   print "<input type=hidden name=action value=\"droneon\">\n";
   print "<center><table border=1>\n";
   print "<tr><td>Series #</td><td>$FORM{'SeriesNum'}</td></tr>\n";
   print "<input type=hidden name=SeriesNum value=\"$FORM{'SeriesNum'}\">\n";
   print "<tr><td>Due Date</td><td>$FORM{'Date'}</td></tr>\n";
   print "<input type=hidden name=Date value=\"$FORM{'Date'}\">\n";
#   print "<tr><td>Time</td><td>$FORM{'Time'}</td></tr>\n";
#   print "<input type=hidden name=Time value=\"$FORM{'Time'}\">\n";
   print "</table><br>\n";

   $t = 0;
   @dties = ();

   foreach $tie (@tieguys) {
      @ties = ();

      (@ties) = split(/\|/, $tie);

      @ties = sort(@ties);

      $h = 0;

      foreach $hb (@ties) {
         $dties[$t] = $hb;
         $t++;
      }
   }

   @dties = sort(@dties);

   $t = 0;
   $ties = ();
   $prevtie = "";

   foreach $dtie (@dties) {
      if ($dtie ne $prevtie) {
         $ties[$t] = $dtie;
         $t++;
      }

      $prevtie = $dtie;
   }

   $b = 0;

   foreach $fa (@fa) {
      $bname = "bid$b";
      $b++;

      print "<input type=hidden name=$bname value=$fa>\n";
   }

   $b = 0;

   foreach $tg (@tieguys) {
      $bname = "tie$b";
      $b++;

      print "<input type=hidden name=$bname value=$tg>\n";
   }

   print "<input type=hidden name=faction value=$FORM{'action'}>\n";

   print "<table border=1>\n";

   foreach $tie (@ties) {
      print "<tr><td>$tie $TNAME{$tie}</td><td><input type=text name=P$tie size=2></td></tr>\n";
   }

   print "</table><br>\n";

   print "<input type=\"submit\" value=\"Update Series Info\">\n";
   print "<input type=\"hidden\" value=\"$passwd\" name=\"DronePassword\">\n";
   print "</form></center>\n";
   &printhtmlfooter;
}




###########################################################################
sub createscreen {
	&printhtmlheader("File Drone Processing");
   print "<form method=POST action=\"$cgi_url/drone_on.pl\">\n";
   print "<input type=hidden name=action value=\"droneprocess\">\n";
   print "<center><table border=1>\n";
   print "<tr><td>Series #</td><td>$FORM{'SeriesNum'}</td></tr>\n";
   print "<input type=hidden name=SeriesNum value=\"$FORM{'SeriesNum'}\">\n";
   print "<tr><td>Due Date</td><td>$FORM{'Date'}</td></tr>\n";
   print "<input type=hidden name=Date value=\"$FORM{'Date'}\">\n";
#   print "<tr><td>Time</td><td>$FORM{'Time'}</td></tr>\n";
#   print "<input type=hidden name=Time value=\"$FORM{'Time'}\">\n";
   print "</table><br>\n";

   $b = 0;

   foreach $fa (@fa) {
      $bname = "bid$b";
      $b++;

      print "<input type=hidden name=$bname value=$fa>\n";
   }

   $b = 0;

   foreach $tg (@tieguys) {
      $bname = "tie$b";
      $b++;

      print "<input type=hidden name=$bname value=$tg>\n";
   }

   print "<input type=hidden name=faction value=$FORM{'action'}>\n";

   if ($more) {
      print "There are no more tied bids!<br><br>\n";
   }
   else {
      print "There are no tied bids!<br><br>\n";
   }

   print "<input type=submit value=\"Update Series Info\"><br>\n";
   print "<input type=\"hidden\" value=\"$passwd\" name=\"DronePassword\">\n";

   print "</form></center>\n";
   &printhtmlfooter;
}


