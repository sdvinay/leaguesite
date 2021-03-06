#!$$perl_command$$
##############################################################################
# notsign.pl - Release players who have not been re-signed
# $Revision: 1.5 $
# $Date: 2003-02-25 23:35:02-08 $
##############################################################################

require "includes.pl";

###########################################################################

&parse_form() || &waste();
$command = "$FORM{'action'}";

($command eq "waiveem") ? &waiveem || &waste();


###########################################################################
sub waiveem 
{
	&lock();
	$league{'canresign'} && &error("Sorry, players can still be re-signed.");
	&processwaivers;
	&unlock();
	print "Location: $teamsurl\n\n";
}


###########################################################################
sub processwaivers {
   $i = 0;

   open(STATFILE, "$stat_file") || &error('Could Not Open Stat File for Reading');
   @slines = <STATFILE>;
   close (STATFILE);

   open(STATFILE, ">$stat_file") || &error('Could Not Open Stat File for Read/Write');
   open(RELEASEFILE, ">$nontender_file") || &error('Could Not Open Release File for Write');

   foreach $sline (@slines) {
      ($playnum, $playname, $pstatus, $pteam, $psalary, $dy, $dm, $dd, $th, $tm, $ts) = split(/:/, $sline);

      chomp($ts);

      if ($pstatus eq "6") {
      	print RELEASEFILE "$playnum:$playname:$pteam:$psalary";
         $pstatus = 0;
         $pteam = "999";
         $psalary = 0;
         $dy = "00";
         $dm = "00";
         $dd = "00";
         $th = "00";
         $tm = "00";
         $ts = "00";
      }

      print STATFILE "$playnum:$playname:$pstatus:$pteam:$psalary:$dy:$dm:$dd:$th:$tm:$ts\n";
   }

   close (STATFILE);
}

