#!$$perl_loc$$
##############################################################################
# Fagent.pl - Enter Free Agent Claims                                        #
# Copyright 1998 Gregory A Greenman                                          #
# Created 03/29/1998              Last Modified 12/19/2001  by vk            #
##############################################################################
# Define Variables

require "includes.pl";

$timeout = 4;

# Done
###########################################################################

&parse_form() || &waste();
$command = "$FORM{'action'}";

if ($command eq "fagent") { &fagent; }
elsif ($command eq "fagentbid") { &fagentbid; }
else { &error("You are wasting my time!"); }


###########################################################################
sub fagent {
   $bland = 0;

   require $rlfile;

   unless ($league{'cansign'}) {
      &error("Sorry, no free agent claims allowed at this time.");
   }

   if (-e $dtempfile) {
      &error("Sorry, no free agent claims allowed at this time.");
   }

   &tmchk;

   if ($bland == 0) {
      &relchk;
	  &printhtmlheader("Free Agent Claim Verification");

      print "<hr>\n";
      print "<h4>$pteam{'number'} $pteam{'name'}</h4>\n";
      print "<h4>$pteam{'manager'}</h4><br>\n";

      print "<form method=POST action=\"$cgi_url/fagent.pl\">\n";
      print "<input type=hidden name=\"action\" value=\"fagentbid\">\n";
      print "<input type=hidden name=\"pteamnum\" value=\"$pteam{'number'}\">\n";
      print "<input type=hidden name=\"password\" value=\"$FORM{'password'}\">\n";

      print "You are bidding on the following player:<br>\n";

      print "<table border=2>\n";
      print "<tr><th>#</th><th>Name</th><th>Bid</th></tr>\n";
      print "<tr><td>$fanum</td><td>$faname</td><td align=right>$FORM{'fabid'}</td></tr>\n";
      print "<input type=hidden name=\"fanum\" value=\"$fanum\">\n";
      print "<input type=hidden name=\"fabid\" value=\"$FORM{'fabid'}\">\n";
      print "</table><br>\n";

      if ($faname) {
         $pteam{'roster'}++;
      }

      $pteam{'cash'} += $FORM{'fabid'};

      print "If necessary, you will release the following players:\n";

      print "<table border=2>\n";
      print "<tr><th></th><th>#</th><th>Name</th><th>Salary</th></tr>\n";

      $x = 0;

      foreach $player (@playarray) {
         ($ord, $pnum, $pteam, $pname, $psalary, $errmsg) = split(/:/, $player);

         print "<input type=hidden name=\"pplay$x\" value=\"$pnum\">\n";
         $x++;
         print "<tr><td>$x</td><td>$pnum</td><td>$pname</td><td align=right>$psalary</td><td>$errmsg<td></tr>\n";

         $pteam{'roster'}--;
         $pteam{'cash'} -= $psalary;
      }

      print "</table><br>\n";

      print "<table border=2>\n";
      print "<tr><th></th><th colspan=2>$pteam{'number'} $pteam{'name'}</th></tr>\n";
      print "<tr><th></th><th>#</th><th>Spent</th></tr>\n";
      print "<tr><td>Before</td><td align=right>$pteam{'sroster'}</td><td align=right>$pteam{'scash'}</td></tr>\n";
      print "<tr><td>After</td><td align=right>$pteam{'roster'}</td><td align=right>$pteam{'cash'}</td></tr>\n";
      print "</table><br>\n";

      if ($playcnt eq 0) {
         print "Uh...do you know what you're doing? You don't seem to have entered any players.<br>\n";
         print "I mean, What's the point?<br><br>\n";
         $error++;
      }
      if ($pteam{'cash'} > $league{'salarycap'}) {
         print "You are over the salary cap with that bid.<br>\n";
         print "You will need to release more players.<br><br>\n";
         $error++;
      }
      if ($pteam{'roster'} > $league{'maxroster'}) {
         print "You will exceed the maximum roster size if you claim that free agent.<br>\n";
         print "Enter at least one player to waive.<br><br>\n";
         $error++;
      }
      if ($ferror) {
         print "$ferror.<br><br>\n";
         $error++;
      }
      unless ($FORM{'fabid'} > 0) {
         print "You haven't bid anything for your free agent claim.<br>\n";
         print "You do understand how this is supposed to work, don't you?<br><br>\n";
      }
      if ($error) {
         print "Your releases have some serious problems.<br>\n";
         print "Click on your browser's \"Back\" button to fix the releases and then reverify them.<br>\n";
      }
      else {
         print "Good job, your free agent claim is legal.<br><br>\n";
         print "<input type=submit value=\"Submit Claim\">\n";
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
}


###########################################################################
sub fagentbid {
   $bland = 0;
   $tland = 0;

   require $rlfile;

   unless ($league{'cansign'}) {
      &error("Sorry, no free agent claims allowed at this time.");
   }

   if (-e $dtempfile) {
      &error("Sorry, no free agent claims allowed at this time.");
   }

   &tmchk;

   if ($bland == 0) {
#      &relchk;

      $i = 0;
      $rels = "";
      $nomatch = 1;
      $player = "pplay$i";

      if ($FORM{$player} ne "") {
         $rels .= "$FORM{$player}";

         $i++;
         $player = "pplay$i";

         while ($FORM{$player} ne "") {
            $rels .= "|$FORM{$player}";

            $i++;
            $player = "pplay$i";
         }
      }

      $rels .= "\n";

      open(FAFILE, "$fafile") || &error('Cannot open Free Agent file for Reading');
      @flines = <FAFILE>;
      close(FAFILE);

      open(FAFILE, ">$fafile") || &error('Cannot open Free Agent file for Read/Write');

      foreach $fline (@flines) {
         ($series, $fanum, $t, $pteamnum, $fabid, $releases) = split(/:/, $fline);

         if ($nomatch && ($series == $league{'series'}) && ($fanum == $FORM{'fanum'}) && ($pteamnum == $FORM{'pteamnum'})) {
            $fabid = $FORM{'fabid'};
            $releases = $rels;

            $nomatch = 0;
         }

         print FAFILE "$series:$fanum:$t:$pteamnum:$fabid:$releases";
      }

      if ($nomatch) {
         $t = time;

         print FAFILE "$league{'series'}:$FORM{'fanum'}:$t:$FORM{'pteamnum'}:$FORM{'fabid'}:$rels";
      }

#      print FAFILE "\n";
      close (FAFILE);
   }

   &printhtmlheader("Free Agent Claims");
   print "<hr>\n";
   print "<h4>$pteam{'number'} $pteam{'name'}</h4>\n";
   print "<h4>$pteam{'manager'}</h4><br><br>\n";
   print "Your Free Agent Claim has been recorded.<br>\n";
   print "</body></html>\n";

#   exec "/www/spencersoft/cgi-bin/trhl/update.pl";
}



###########################################################################
sub tmchk {
   open(TEAMFILE,"$team_file") || &error('Could Not Open Team File for Reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   $bland = 1;

   tloop:foreach $tline (@tlines) {
      ($teamnum, $passwd, $tmname, $manager, $a, $b, $numown, $numbid, $cashspent, $cashbid) = split(/:/, $tline);

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
}



###########################################################################
sub relchk {
   $error = 0;

   open(STATFILE,"$stat_file") || &error('Could Not Open Stat File for Reading');
   @slines = <STATFILE>;
   close(STATFILE);

   $i = 0;

#   if ($FORM{'fagent'}) {
      $player = join(":", $FORM{'fagent'}, "999");
      @plarray[$i] = $player;
      $i++;
#   }
   if ($FORM{'pplay0'}) {
      $player = join(":", $FORM{'pplay0'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay1'}) {
      $player = join(":", $FORM{'pplay1'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay2'}) {
      $player = join(":", $FORM{'pplay2'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay3'}) {
      $player = join(":", $FORM{'pplay3'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay4'}) {
      $player = join(":", $FORM{'pplay4'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay5'}) {
      $player = join(":", $FORM{'pplay5'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay6'}) {
      $player = join(":", $FORM{'pplay6'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }
   if ($FORM{'pplay7'}) {
      $player = join(":", $FORM{'pplay7'}, $pteam{'number'}, $i);
      @plarray[$i] = $player;
      $i++;
   }

   @plarray = sort(@plarray);

   $playcnt = @plarray;
   $error = 0;

   if ($playcnt gt 0) {
      for ($i = 0; $i < $playcnt; $i++) {
         ($parray[$i], $ptarray[$i], $ordarray[$i]) = split(/:/, $plarray[$i]);
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
      $x = 0;
      $prevplay = "";

      sloop: foreach $slines_line (@slines) {
         ($playnum, $playname, $pstatus, $pteam, $psalary) = split(/:/, $slines_line);

         chomp($psalary);

         while ($playnum gt $parray[$i]) {
            if ($ptarray[$i] eq "999") {
               $fanum = $parray[$i];
               $faname = "";
               $ferror = "The Player You are Trying to Claim Does Not Exist.";
            }
            else {
               $errmsg = "Player Not Found";
               $error += 1;

               @playarray[$x] = join(":", $ordarray[$i], $parray[$i], $ptarray[$i], "", "", $errmsg);
               $x++;
            }

            $prevplay = $parray[$i];
            $i++;

            last sloop if ($i eq $playcnt);
         }

         while ($playnum eq $parray[$i]) {
            $errmsg = "";

            if (($pteam ne $ptarray[$i]) && ($ptarray[$i] ne "999")) {
               $errmsg = "Player Not On This Team";
               $error += 1;
            }
            if ($pstatus eq "9") {
               $errmsg = "Cannot release waiver penalties";
               $error += 1;
            }

            if ($ptarray[$i] eq "999") {
               if ($pteam eq "999") {
                  $fanum = $parray[$i];
                  $faname = $playname;
               }
               else {
                  $fanum = $parray[$i];
                  $faname = $playname;
                  $ferror = "The Player You are Trying to Claim is Not a Free Agent.";
               }
            }
            else {
               @playarray[$x] = join(":", $ordarray[$i], $parray[$i], $ptarray[$i], $playname, $psalary, $errmsg);
               $x++;
            }

            $prevplay = $parray[$i];
            $i++;

            last sloop if ($i eq $playcnt);
         }
      }

      while ($i lt $playcnt) {
         if ($ptarray[$i] eq "999") {
            $fanum = $parray[$i];
            $faname = "";
            $ferror = "The Player You are Trying to Claim Does Not Exist.";
         }
         else {
            $errmsg = "Player Not Found";
            $error += 1;

            @playarray[$x] = join(":", $ordarray[$i], $parray[$i], $ptarray[$i], "", "", $errmsg);
            $x++;
         }

         $i++;
      }
   }

   @playarray = sort(@playarray);
}

