#!$$perl_command$$
##############################################################################
# Tradeem.pl - Verify Trades are legal                                       #
# Copyright 1997 Gregory A Greenman
# $Revision$
# $Date$
##############################################################################

require "includes.pl";

###########################################################################

&parse_form || &waste;
$command = "$FORM{'action'}";

if ($command eq "tradeem") { &tradeem; }
elsif ($command eq "tradeupdt") { &tradeupdt; }
else { &waste; }


###########################################################################
sub tradeem {
   $bland = 0;

   require $rlfile;

   unless ($league{'cantrade'}) {
      &error("Sorry, no trades allowed at this time.");
   }
   
   &tmchk;

   if ($bland == 0) {
      &trdchk;
	  &printhtmlheader("Trade Verification");
      print "<h4>$pteam{'number'} $pteam{'name'}</h4>\n";
      print "<h4>$pteam{'manager'}</h4><br>\n";

      print "<form method=POST action=\"$cgi_url/tradeem.pl\">\n";
      print "<input type=hidden name=\"action\" value=\"tradeupdt\">\n";
      print "<input type=hidden name=\"pteamnum\" value=\"$pteam{'number'}\">\n";
      print "<input type=hidden name=\"password\" value=\"$FORM{'password'}\">\n";
      print "<input type=hidden name=\"oteamnum\" value=\"$oteam{'number'}\">\n";

      print "You are trading away the following players:<br>\n";
      print "<table border=2>\n";
      print "<tr><th colspan=5>$pteam{'number'} $pteam{'name'}</th></tr>\n";
      print "<tr><th></th><th>#</th><th>Name</th><th>Salary</th></tr>\n";

      $x = 0;

      foreach $player (@playarray) {
         ($pnum, $pteam, $pname, $psalary, $errmsg) = split(/:/, $player);

         if ($pteam eq $pteam{'number'}) {
            print "<input type=hidden name=\"pplay$x\" value=\"$pnum\">\n";
            $x++;
            print "<tr><td>$x</td><td>$pnum</td><td>$pname</td><td align=right>$psalary</td><td>$errmsg<td></tr>\n";

            $pteam{'roster'}--;
            $oteam{'roster'}++;

            $pteam{'cash'} -= $psalary;
            $oteam{'cash'} += $psalary;
         }
      }

      print "</table><br>\n";

      print "in exchange for:<br>\n";

      print "<table border=2>\n";
      print "<tr><th colspan=5>$oteam{'number'} $oteam{'name'}</th></tr>\n";
      print "<tr><th></th><th>#</th><th>Name</th><th>Salary</th></tr>\n";

      $x = 0;

      foreach $player (@playarray) {
         ($pnum, $pteam, $pname, $psalary, $errmsg) = split(/:/, $player);

         if ($pteam eq $oteam{'number'}) {
            print "<input type=hidden name=\"oplay$x\" value=\"$pnum\">\n";
            $x++;
            print "<tr><td>$x</td><td>$pnum</td><td>$pname</td><td align=right>$psalary</td><td>$errmsg</td></tr>\n";

            $pteam{'roster'}++;
            $oteam{'roster'}--;

            $pteam{'cash'} += $psalary;
            $oteam{'cash'} -= $psalary;
         }
      }

      print "</table><br>\n";

      print "<table border=2>\n";
      print "<tr><th></th><th colspan=2>$pteam{'number'} $pteam{'name'}</th><th colspan=2>$oteam{'number'} $oteam{'name'}</th></tr>\n";
      print "<tr><th></th><th>#</th><th>Spent</th><th>#</th><th>Spent</th></tr>\n";
      print "<tr><td>Before</td><td align=right>$pteam{'sroster'}</td><td align=right>$pteam{'scash'}</td><td align=right>$oteam{'sroster'}</td><td align=right>$oteam{'scash'}</td></tr>\n";
      print "<tr><td>After</td><td align=right>$pteam{'roster'}</td><td align=right>$pteam{'cash'}</td><td align=right>$oteam{'roster'}</td><td align=right>$oteam{'cash'}</td></tr>\n";
      print "</table><br>\n";

      if ($playcnt eq 0) {
         print "Uh...do you know what you're doing? You don't seem to have entered any players.<br>\n";
         print "I mean, What's the point?<br><br>\n";
         $error++;
      }
      if ($pteam{'number'} eq $oteam{'number'}) {
         print "You're making a trade with yourself?<br>\n";
         print "This is some sort of joke, right?<br><br>\n";
         $error++;
      }
      if (($pteam{'roster'} > $league{'maxroster'}) && $league{'captrade'}) {
         print "Hey, you can only have $league{'maxroster'} players.<br>\n";
         print "Sorry...no can do on that trade.<br><br>\n";
         $error++;
      }
      if (($oteam{'roster'} > $league{'maxroster'}) && $league{'captrade'}) {
         print "Hey, your trade partner can only have $league{'maxroster'} players.<br>\n";
         print "Sorry...no can do on that trade.<br><br>\n";
         $error++;
      }
      if (($pteam{'cash'} > $league{'salarycap'}) && $league{'captrade'}) {
         print "Hey, did you forget about the salary cap?<br>\n";
         print "Sorry...no can do on that trade.<br><br>\n";
         $error++;
      }
      if (($oteam{'cash'} > $league{'salarycap'}) && $league{'captrade'}) {
         print "Hey, did your trade partner forget about the salary cap?<br>\n";
         print "Sorry...no can do on that trade.<br><br>\n";
         $error++;
      }
      if ($error) {
         print "Your trade has some serious problems.<br>\n";
         print "Click on your browser's \"Back\" button to fix the trade and then reverify it.<br>\n";
      }
      else {
         print "Good job, your trade is legal.<br><br>\n";
         print "<input type=submit value=\"Submit Trade\">\n";
      }

      print "</form></center>\n";
      print "</body></html>\n";

   }
   elsif ($bland == 1) {
      &error("Your team number doesn't seem to exist.");
   }
   elsif ($bland == 2) {
      &error("The password entered is not correct for the team number entered.");
   }
   elsif ($bland == 3) {
      &error("Your trade partner's team number doesn't seem to exist.");
   }
}


###########################################################################
sub tradeupdt {
   $bland = 0;
   $tland = 0;

   require $rlfile;

   unless ($league{'cantrade'}) {
      &error("Sorry, no trades allowed at this time.");
   }

   &tmchk;

   if ($bland == 0) {
      &trdchk;

      &processtrade;

      open(TFILE, ">>$tradefile");

      print TFILE "$league{'series'}:$FORM{'pteamnum'}:";

      $i = 0;
      $player = "pplay$i";

      if ($FORM{$player} ne "") {
         print TFILE "$FORM{$player}";

         $i++;
         $player = "pplay$i";

         while ($FORM{$player} ne "") {
            print TFILE ",$FORM{$player}";

            $i++;
            $player = "pplay$i";
         }
      }

      print TFILE ":$FORM{'oteamnum'}:";

      $i = 0;
      $player = "oplay$i";

      if ($FORM{$player} ne "") {
         print TFILE "$FORM{$player}";

         $i++;
         $player = "oplay$i";

         while ($FORM{$player} ne "") {
            print TFILE ",$FORM{$player}";

            $i++;
            $player = "oplay$i";
         }
      }

      print TFILE "\n";
      close (TFILE);
   }
      require "$cgi_dir/update2.pl";

#   exec "/www/spencersoft/cgi-bin/trhl/update.pl";

   print "Location: $teamsurl\n\n";
}


###########################################################################
sub processtrade {
   $i = 0;

   open(STATFILE, "$stat_file") || &error('Could Not Open Stat File for Reading');
   @slines = <STATFILE>;
   close (STATFILE);

   open(STATFILE, ">$stat_file") || &error('Could Not Open Stat File for Read/Write');

   foreach $sline (@slines) {
      ($playnum, $playname, $pstatus, $pteam, $psalary, $dy, $dm, $dd, $th, $tm, $ts) = split(/:/, $sline);

      chomp($ts);

      if ($playnum eq $parray[$i]) {
         if ($ptarray[$i] eq $FORM{'pteamnum'}) {
            $newteam = $FORM{'oteamnum'};
         }
         else {
            $newteam = $FORM{'pteamnum'};
         }

         if ($pstatus == 6) {
            $pstatus = 5;
         }

         print STATFILE "$playnum:$playname:$pstatus:$newteam:$psalary:$dy:$dm:$dd:$th:$tm:$ts\n";

         $i++;
      }
      else {
         print STATFILE "$sline";
      }
   }

   close (STATFILE);
}



###########################################################################
sub tmchk {
   open(TEAMFILE,"$team_file") || &error('Could Not Open Team File for Reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   $bland = 1;
   $onf = 3;

   tloop:foreach $tline (@tlines) {
      ($teamnum, $passwd, $tmname, $manager, $a, $b, $numown, $numbid, $cashspent, $cashbid) = split(/:/, $tline);

      if ($teamnum eq $FORM{'oteamnum'}) {
         $toteam = $tline;

         $oteam{'number'}  = $FORM{'oteamnum'};
         $oteam{'name'}    = $tmname;
         $oteam{'manager'} = $manager;
         $oteam{'roster'}  = $numown + $numbid;
         $oteam{'cash'}    = $cashspent + $cashbid;
         $oteam{'sroster'} = $oteam{'roster'};
         $oteam{'scash'}   = $oteam{'cash'};
         $onf = 0;
      }

      if ($teamnum eq $FORM{'pteamnum'}) {
         if ($FORM{'password'} eq $passwd) {
            $tpteam = $tline;

            $pteam{'number'}  = $FORM{'pteamnum'};
            $pteam{'name'}    = $tmname;
            $pteam{'manager'} = $manager;
            $pteam{'roster'}  = $numown + $numbid;
            $pteam{'cash'}    = $cashspent + $cashbid;
            $pteam{'sroster'} = $pteam{'roster'};
            $pteam{'scash'}   = $pteam{'cash'};

            $bland = 0;
         }
         else {
            $bland = 2;
         }
      }
   }

   if ($bland == 0) {
      $bland = $onf;
   }
}



###########################################################################
sub trdchk {
   $error = 0;

   open(STATFILE,"$stat_file") || &error('Could Not Open Stat File for Reading');
   @slines = <STATFILE>;
   close(STATFILE);

   $i = 0;

   if ($FORM{'pplay0'}) {
      $player = join(":", $FORM{'pplay0'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay1'}) {
      $player = join(":", $FORM{'pplay1'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay2'}) {
      $player = join(":", $FORM{'pplay2'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay3'}) {
      $player = join(":", $FORM{'pplay3'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay4'}) {
      $player = join(":", $FORM{'pplay4'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay5'}) {
      $player = join(":", $FORM{'pplay5'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay6'}) {
      $player = join(":", $FORM{'pplay6'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay7'}) {
      $player = join(":", $FORM{'pplay7'}, $pteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay0'}) {
      $player = join(":", $FORM{'oplay0'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay1'}) {
      $player = join(":", $FORM{'oplay1'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay2'}) {
      $player = join(":", $FORM{'oplay2'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay3'}) {
      $player = join(":", $FORM{'oplay3'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay4'}) {
      $player = join(":", $FORM{'oplay4'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay5'}) {
      $player = join(":", $FORM{'oplay5'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay6'}) {
      $player = join(":", $FORM{'oplay6'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }
   if ($FORM{'oplay7'}) {
      $player = join(":", $FORM{'oplay7'}, $oteam{'number'});
      @playarray[$i] = $player;
      $i++;
   }

   @playarray = sort(@playarray);

   $playcnt = @playarray;
   $error = 0;

   if ($playcnt gt 0) {
      for ($i = 0; $i < $playcnt; $i++) {
         ($parray[$i], $ptarray[$i]) = split(/:/, $playarray[$i]);
#         $poarray[$i] =~ s/^\s*(.*?)\s*$/$1/;
#         $poarray[$i] =~ s/^0+//;
#         $poarray[$i] = "0" if ($poarray[$i] eq "");
#         $plarray[$i] =~ s/^\s*(.*?)\s*$/$1/;
#         $plarray[$i] =~ s/^0+//;
#         $plarray[$i] = "0" if ($plarray[$i] eq "");
#         $prarray[$i] =~ s/^\s*(.*?)\s*$/$1/;
#         $prarray[$i] =~ s/^0+//;
#         $prarray[$i] = "0" if ($prarray[$i] eq "");
      }

      $i = 0;
#      $prevplay = "";

      sloop: foreach $slines_line (@slines) {
         ($playnum, $playname, $pstatus, $pteam, $psalary) = split(/:/, $slines_line);

         chomp($psalary);

         while ($playnum gt $parray[$i]) {
            $errmsg = "Player Not Found";
            $error += 1;

            @playarray[$i] = join(":", $parray[$i], $ptarray[$i], "", "", $errmsg);
#            $prevplay = $parray[$i];
            $i++;

            last sloop if ($i eq $playcnt);
         }

         while ($playnum eq $parray[$i]) {
            $errmsg = "";

            if ($pteam ne $ptarray[$i]) {
               $errmsg = "Player Not On This Team";
               $error += 1;
            }
            if ($pstatus eq "9") {
               $errmsg = "Cannot trade waiver penalties";
               $error += 1;
            }

            @playarray[$i] = join(":", $parray[$i], $ptarray[$i], $playname, $psalary, $errmsg);
            $prevplay = $parray[$i];
            $i++;

            last sloop if ($i eq $playcnt);
         }
      }

      while ($i lt $playcnt) {
         $errmsg = "Player Not Found";
         $error += 1;

         @playarray[$i] = join(":", $parray[$i], $ptarray[$i], "", "", $errmsg);
         $i++;
      }
   }
#   else {
#   }
}
