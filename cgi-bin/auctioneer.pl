#!$$perl_command$$
##############################################################################
# Auctioneer.pl                                                              #
# Copyright 1997 Gregory A Greenman                                          #
# Created 02/03/1997              Last Modified 02/20/2003 by vk             #
##############################################################################
use File::Copy;

# Define Variables


require "includes.pl";

$timeout = 4;

&sellem;

###########################################################################
sub sellem {
   $goforit = 0;

   require $rlfile;

   unless ($league{'canbid'}) {
      &error("Sorry, no Bids allowed at this time.");
   }

   &chktemp;

   if ($goforit) {

	&updtstat;

	&soldfile;

	unlink "$atempfile";

	require "$cgi_dir/update2.pl";
   }
   else {
      &error('???');
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
   if ($mnth < 10) {
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

   $year = 1900 + $year;

   $long_date = "$months[$mon] $mday, $year at $hour\:$min\:$sec";
}



###########################################################################
sub chktemp {
   &gettime;

   $scount = 0;

   while ((-e "$btempfile") && ($scount < $timeout)) {
      sleep 2;
      $scount++;
   }

   if ($scount >= $timeout) {
      &error('Time Out - Try Again Later');
   }

	if (-e "$atempfile") {
		&error('Auctioneer already in process');
	}
	else 
	{
		while (-e "$btempfile") 
		{
			sleep 1;
		}

		open(WAITFILE, ">$atempfile") || &error('Cannot open Wait File for Read/Write');
		print WAITFILE "$year:$mnth:$mday:$hour:$min:$sec\n";
		close(WAITFILE);
		
		open(RUNFILE, ">>$runfile") || &error('Cannot open Run File for Read/Write');
		print RUNFILE "\n$year:$mnth:$mday:$hour:$min:$sec";
		close(RUNFILE);
		
		$goforit = 1;
	}
}



###########################################################################
sub updtstat {
   copy("$stat_file", "$stat_bak");

   open(STATFILE,"$stat_file") || &error('Cannot open stat file for reading');
   @slines = <STATFILE>;
   close(STATFILE);

   %soldcash = ("000", 0, "001", 0, "002", 0, "003", 0,
                "010", 0, "011", 0, "012", 0, "013", 0,
                "020", 0, "021", 0, "022", 0, "023", 0,
                "100", 0, "101", 0, "102", 0, "103", 0,
                "110", 0, "111", 0, "112", 0, "113", 0,
                "120", 0, "121", 0, "122", 0, "123", 0,);

   open(STATFILE,">$stat_file") || &error('Cannot open stat file for read/write');

   $i = 0;

   sloop: foreach $slines_line (@slines) {
      ($playnum, $playname, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec) = split(/:/, $slines_line);
      $lbid = join(":", $byr, $bmon, $bday, $bhr, $bmin, $bsec);

      chomp($bsec);

      if (($pstatus eq "1") || ($pstatus eq "2")) {
         $pstatus = "3";
      }
#      elsif (($pstatus eq "2") && ($lbid lt $lastrun)) {
#      elsif ($pstatus eq "2")  {
#         $pstatus = "3";
#      }
      elsif ($pstatus eq "3") {
         $pstatus = "4";
      }
      elsif ($pstatus eq "4") {
         $pstatus = "5";
         $soldcash{$pteam} += $psalary;

         $soldplyr[$i] = join(":", $pteam, $playnum, $playname, $psalary);
         $i++;
      }

      $pline = join(":", $playnum, $playname, $pstatus, $pteam, $psalary, $byr, $bmon, $bday, $bhr, $bmin, $bsec);

      print STATFILE "$pline\n";
   }

   close(STATFILE);

   @soldplyr = sort(@soldplyr);
}



###########################################################################
sub soldfile {
	open(BFILE, ">>$sfile") || &error('Cannot Open Sold File for Append');
	
	open(TEAMFILE,"$team_file") || &error('Could Not Open Team File for Reading');
	@tlines = <TEAMFILE>;
	close(TEAMFILE);
	
	foreach $tline (@tlines)
	{
		($tnum,$passwd,$team,$dummy) = split(/:/,$tline);
		# pad/crop team name to 18 chars
		$teamname{$tnum} = substr("$team                  ", 0, 18);
	}

   foreach $splayer (@soldplyr) {
      ($pteam, $playnum, $playname, $psalary) = split(/:/, $splayer);

      print BFILE "$long_date\t$pteam\t$teamname{$pteam}\t$playnum\t$playname\t$psalary\n";
   }

   close(BFILE);
}

