#!$$perl_loc$$
##############################################################################
# Teamdata.pl - Team Data Verification                                       #
# Copyright 1997 Gregory A Greenman                                          #
# Created 02/03/1997              Last Modified 2/11/2003  by vk             #
##############################################################################
# Define Variables

require "includes.pl";

# Done
###########################################################################

&parse_form || &waste;
$command = "$FORM{'action'}";

if ($command eq "teamdata") { &UpdateData; }
elsif ($command == "updtteam") { &updtteam; }
else { &waste; }


###########################################################################
sub UpdateData {
   $bland = 0;

#   &readleague;
   require $rlfile;
   
   &tmchk;

   if ($bland == 0) {
   	  &printhtmlheader("Team Data Verification");
      print "<h4>$teamnum $team</h4>\n";
      print "<h4>$man</h4><br>\n";

      print "<form method=POST action=\"$cgi_url/teamdata.pl\">\n";
      print "<input type=hidden name=\"action\" value=\"updtteam\">\n";
      print "<input type=hidden name=\"teamnum\" value=\"$teamnum\">\n";
      print "<input type=hidden name=\"password\" value=\"$passwd\">\n";

      print "You made the following changes:<br>\n";
      print "<table border=2>\n";
      print "<tr><th></th><th>Old Data</th><th>New Data</th></tr>\n";

      $updtteampg = 0;

      if ($FORM{'newpass'} ne "") {
         print "<tr><td>Password</td><td width=20>$passwd</td><td>$FORM{'newpass'}</td></tr>\n";
         print "<input type=hidden name=\"newpass\" value=\"$FORM{'newpass'}\">\n";
      }
      else {
         print "<input type=hidden name=\"newpass\" value=\"$passwd\">\n";
      }

      if ($FORM{'newname'} ne "") {
         print "<tr><td>Team Name</td><td>$team</td><td>$FORM{'newname'}</td></tr>\n";
         print "<input type=hidden name=\"newname\" value=\"$FORM{'newname'}\">\n";
         $updtteampg = 1;
      }
      else {
         print "<input type=hidden name=\"newname\" value=\"$team\">\n";
      }

      if ($FORM{'newowner'} ne "") {
         print "<tr><td>Owner Name</td><td>$man</td><td>$FORM{'newowner'}</td></tr>\n";
         print "<input type=hidden name=\"newowner\" value=\"$FORM{'newowner'}\">\n";
         $updtteampg = 1;
      }
      else {
         print "<input type=hidden name=\"newowner\" value=\"$man\">\n";
      }

      if ($FORM{'newemail'} ne "") {
         print "<tr><td>E-Mail Address</td><td>$email</td><td>$FORM{'newemail'}</td></tr>\n";
         print "<input type=hidden name=\"newemail\" value=\"$FORM{'newemail'}\">\n";
         $updtteampg = 1;
      }
      else {
         print "<input type=hidden name=\"newemail\" value=\"$email\">\n";
      }

      print "<input type=hidden name=\"updtteampg\" value=\"$updtteampg\">\n";

#      @yesno = ("No", "Yes");

#      $osendstr = $yesno[$send];
#      $nsendstr = $yesno[$FORM{'sendemail'}];

#      print "<tr><td>Send E-Mail</td><td>$osendstr</td><td>$nsendstr</td></tr>\n";
#      print "<input type=hidden name=\"sendemail\" value=\"$FORM{'sendemail'}\">\n";

      print "</table><br>\n";

      print "Please verify the changes you have made.<br>\n";
      print "If they are acceptable, please click \"Update Data\".<br>\n";
      print "If not, please click on your browser's \"Back\" button and correct them.<br><br>\n";

      print "<input type=submit value=\"Update Data\">\n";

      print "</form></center>\n";
      print "</body></html>\n";

#      &prnt_footer;
   }
   elsif ($bland == 1) {
      &error("Team Number Does Not Exist");
   }
   elsif ($bland == 2) {
      &error("The Password Is Not Correct for This Team Number");
   }
}


###########################################################################
sub updtteam {
   &updtteams;

   if ($FORM{'updtteampg'}) {
      require "$cgi_dir/update2.pl";
   }

   print "Location: $teamsurl\n\n";
}


###########################################################################
sub updtteams {
   open(TEAMFILE,"$team_file") || &error('Could Not Open Team File for Reading');
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   open(TEAMFILE,">$team_file") || &error('Could Not Open Team File for Read/Write');

   foreach $team (@tlines) {
      ($teamnum, $passwd, $teamname, $manager, $email, $stad, $nown, $nbid, $cspent, $cbid) = split(/:/, $team);

      chomp($cbid);

      if ($teamnum eq $FORM{'teamnum'}) {
         $passwd = $FORM{'newpass'};
         $teamname = $FORM{'newname'};
         $manager = $FORM{'newowner'};
         $email = $FORM{'newemail'};
#         $sendemail = $FORM{'sendemail'};
      }

      $pline = join(":", $teamnum, $passwd, $teamname, $manager, $email, $stad, $nown, $nbid, $cspent, $cbid);
      print TEAMFILE "$pline\n";
   }

   close(TEAMFILE);
}



###########################################################################
sub tmchk {
   open(TEAMFILE,"$team_file") || &error("Could not open team file for reading");
   @tlines = <TEAMFILE>;
   close(TEAMFILE);

   $bland = 1;

   tloop:foreach $tlines_line (@tlines) {
      ($teamnum,$passwd,$team,$man,$email,$stadium,$nown, $nbid, $nrel, $ntrd, $cspent, $cbid, $crel, $ctrd) = split(/:/,$tlines_line);

      chomp($ctrd);

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

