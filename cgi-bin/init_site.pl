#!$$perl_command$$

##############################################################################
# init_site.pl -- Runs upon installation, initializes the site

require "includes.pl";

#generate all the HTML
print "about to update2\n";
require "update2.pl";

#populate .htpasswd
print "about to populate .htpasswd\n";
open(TEAMFILE, $team_file) || die("could not open team file");
@tlines = <TEAMFILE>;
close(TEAMFILE);

foreach $tline (@tlines)
{
	($teamnum,$passwd) = split(/:/,$tline);
	print "about to updatehtaccess($teamnum,$passwd)\n";
	&UpdateHTAccess($teamnum, $passwd) || die("failure to update passwd in .htaccess");
}
