#!$$perl_loc$$
##############################################################################
# Keepers.pl - Entry of Players to be Retained                               #
# Copyright 1997 Gregory A Greenman                                          #
# Created 02/03/1997              Last Modified 12/19/2001  by vk            #
##############################################################################
# Define Variables

require "includes.pl";

# Done
###########################################################################

$parsed = 0;

if ($ENV{'QUERY_STRING'} ne '') {
   $command = "$ENV{'QUERY_STRING'}";
}
else {
   &parse_form;

   $parsed = 1;

   $command = "$FORM{'action'}";
}

if ($parsed) {
   require $rlfile;

   if ($command eq "editkeepers") {
      &editkeepers;
   }
   elsif ($command eq "postkeepers") {
      &postkeepers;
   }

   else {
      &waste;
   }
}
else {
   &waste;
}


###########################################################################
# Parse Form Subroutine

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

      $FORM{$name} = $value;
   }
}



###########################################################################
sub editkeepers {
   $bland = 0;

   unless ($league{'canresign'}) {
      &error('You cannot re-sign players at this time.');
   }
   
   &tmchk;

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

   $totsalary = 0;
   $ressalary = 0;
   $totroster = 0;
   $resroster = 0;

   $i = 0;

   foreach $statline (@slines) {
      ($pnum, $pname, $pstat, $pteam, $psalary) = split(/:/, $statline);

      if ($pteam eq $teamnum) {
         $mline = join(":", $pname, $pnum, $pstat, $psalary);

         $totsalary += $psalary;
         $totroster++;

         if ($pstat == 5) {
            $ressalary += $psalary;
            $resroster++;
         }

         $players[$i] = $mline;

         $i++;
      }
   }

   @players = sort(@players);

   $totavail = $league{'salarycap'} - $totsalary;
   $resavail = $league{'salarycap'} - $ressalary;
   $totrosta = $league{'maxroster'} - $totroster;
   $resrosta = $league{'maxroster'} - $resroster;

   if ($bland == 0) {
     &printhtmlheader("Player Re-Signing");

      print "<h4>$teamnum $team</h4>\n";
      print "<h4>$man</h4><br>\n";

      print "<table border=2>\n";
      print "<tr><th colspan=3><font size=+2>Cash</font></th></tr>\n";
      print "<tr><th></th><th>Current</th><th>Re-Signed Players</th></tr>\n";
      print "<tr><td>Spent</td><td align=right>$totsalary</td><td align=right>$ressalary</td></tr>\n";
      print "<tr><td>Available</td><td align=right>$totavail</td><td align=right>$resavail</td></tr>\n";
      print "</table><br>\n";

      print "<table border=2>\n";
      print "<tr><th colspan=3><font size=+2>Roster Slots</font></th></tr>\n";
      print "<tr><th></th><th>Current</th><th>Re-Signed Players</th></tr>\n";
      print "<tr><td>Used</td><td align=right>$totroster</td><td align=right>$resroster</td></tr>\n";
      print "<tr><td>Available</td><td align=right>$totrosta</td><td align=right>$resrosta</td></tr>\n";
      print "</table><br>\n";

      print "<form method=POST action=\"$ENV{REQUEST_URI}\">\n";
      print "<input type=hidden name=\"action\" value=\"postkeepers\">\n";
      print "<input type=hidden name=\"teamnum\" value=\"$teamnum\">\n";
      print "<input type=hidden name=\"password\" value=\"$passwd\">\n";

      print "<table border=2>\n";
      print "<tr><th></th><th>Re-sign?</th><th>#</th><th>Player</th><th>Salary</th></tr>\n";

      $n = 1;

      foreach $player (@players) {
         ($pname, $pnum, $pstat, $psalary) = split(/:/, $player);

         if ($pstat == 5) {
            $chk = "checked";
         }
         else {
            $chk = "";
         }

         print "<tr><td align=right>$n</td><td align=center><input type=\"checkbox\" name=\"p$pnum\" value=\"1\" $chk></td><td>$pnum</td><td>$pname</td><td align=right>$psalary</td></tr>\n";
         print "<input type=hidden name=\"p$n\" value=\"$pnum\">\n";

         $n++;
      }

      print "</table><br>\n";

      $n--;
      print "<input type=hidden name=\"numplyrs\" value=\"$n\">\n";

      print "<input type=submit value=\"Update Players\">\n";

      print "</form></center>\n";
   }
   elsif ($bland == 1) {
      &error("Team Number Does Not Exist");
   }
   elsif ($bland == 2) {
      &error("The Password Is Not Correct for This Team Number");
   }
}


###########################################################################
sub postkeepers {
   for ($i=1; $i <= $FORM{'numplyrs'}; $i++) {
      $plist[$i-1] = $FORM{"p$i"};
   }

   @plist = sort(@plist);

   open(STATFILE, "$stat_file") || &error('Could not open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

   $i = 0;

   open(STATFILE, ">$stat_file") || &error('Could not open stat file for read/write');

   foreach $statline (@slines) {
      chomp($statline);

      ($pnum, $pname, $pstat, $pteam, $psalary, $by, $bm, $bd, $bh, $be, $bs) = split(/:/, $statline);

      if ($pnum eq $plist[$i]) {
         if ($FORM{"p$plist[$i]"} == 1) {
            $pstat = 5;
         }
         else {
            $pstat = 6;
         }

         $statline = join(":", $pnum, $pname, $pstat, $pteam, $psalary, $by, $bm, $bd, $bh, $be, $bs);

         $i++;
      }

      print STATFILE "$statline\n";
   }

   close(STATFILE);

   &editkeepers;
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
sub tmchk {
   open(TEAMFILE,"$team_file") || &error("Could not open team file for reading");
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   $bland = 1;

   tloop:foreach $tlines_line (@tlines) {
      ($teamnum,$passwd,$team,$man,$email,$stadium,$nown, $nbid, $nrel, $ntrd, $cspent, $cbid, $crel, $ctrd, $send) = split(/:/,$tlines_line);

      chomp($send);

      if ($teamnum eq $FORM{'teamnum'}) {
         if ($FORM{'password'} eq $passwd) {
            $bland = 0;
         }
         else {
            $bland = 2;
         }

         last tloop;
      }
   }
}

