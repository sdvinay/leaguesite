#!/usr/local/bin/perl
##############################################################################
# notsign.pl - Release players who have not been re-signed                   #
# Copyright 1997 Gregory A Greenman                                          #
# Created 02/03/1997              Last Modified 02/02/2003  by vk            #
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
   if ($command == "waiveem") {
      &waiveem;
   }
   else {
      &error("You are wasting my time");
   }
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
sub waiveem {
   $bland = 0;

   require $rlfile;

   if ($league{'canresign'}) {
      &error("Sorry, players can still be re-signed.");
   }
   
   &processwaivers;

print "Location: $teamsurl\n\n";

#   exec "/home/www/spencersoft/cgi-bin/trhl/update.pl";
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

