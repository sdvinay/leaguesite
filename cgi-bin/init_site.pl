#!$$perl_command$$

##############################################################################
# init_site.pl -- Runs upon installation, initializes the site
# $Revision$
# $Date$

require "includes.pl";

#generate all the HTML
require "update2.pl";

#populate .htpasswd
open(TEAMFILE, $team_file) || die("could not open team file");
@tlines = <TEAMFILE>;
close(TEAMFILE);

foreach $tline (@tlines)
{
	($teamnum,$passwd) = split(/:/,$tline);
	&UpdateHTAccess($teamnum, $passwd) || die("failure to update passwd in .htaccess");
}
