#!$$perl_command$$

##############################################################################
# init_site.pl -- Runs upon installation, initializes the site
# $Revision: 1.5 $
# $Date: 2003-03-01 00:13:23-08 $

require "includes.pl";

&force_unlock();
&lock();

#generate all the HTML
require "update2.pl";

#populate .htpasswd
open(TEAMFILE, $team_file) || die("could not open team file");
@tlines = <TEAMFILE>;
close(TEAMFILE);

foreach $tline (@tlines)
{
	($teamnum,$passwd) = split(/:/,$tline);
	&UpdateHTPasswd($teamnum, $passwd) || die("failure to update passwd in .htaccess");
}

&UpdateHTPasswd("drone", $league{'dronepw'});

&unlock();