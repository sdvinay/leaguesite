readme.txt for the TRHL web site installation package

I.     Quick'n'dirty guide to get started
II.    In-depth explanation of installer
III.   In-depth explanation of web site scripts
IV.    Greg Greenman's license agreement

I.	Quick'n'dirty guide to get started

1. Open up manifest.txt in a text editor.  Each line describes a
   directory of files which is underneath the base directory and will
   be installed somewhere on your system. Each line has four
   tab-separated fields: the name of the source directory, the
   location for it to be installed, the URL to get to that installed
   directory, and some instructions for installing that directory.
   Edit the 2nd and 3rd field of each line to something that will work
   on your system (for most people, that means everything but cgi-bin
   needs to be somewhere under your public_html directory, and cgi-bin
   needs to be somewhere under your cgi-bin directory).  The
   destination directories do not need to exist already; the installer
   will create them if necessary.  It's probably a good idea to use
   subdirectories specific for this website, rather than your base
   public_html and cgi-bin directories, so that you can easily remove
   this installation.  It's OK to install multiple source directories
   into the same destination directory (indeed, it's recommended; no
   reason that static_html and generated_html need to go to different
   places).

2. Open up config.txt.  You can ignore most of the settings here, but
   check that perl_loc is valid for your system, and change it if
   necessary (you can find the location of perl on your system by
   executing `which perl`).  You can change the league name here if
   you want.

3. Install the site by running "perl install.pl".  This will create
   directories if needed, copy all the files over, and populate the
   files with the proper pathnames and URLs for your installation
   (getting these values out of manifest.txt and config.txt)

4. Hit your site with a browser, by going to the URL you specified for
   static_html in manifest.txt.  You should see the web site frameset.

5. Go to the "Update Page" (second-to-last link on the left nav), and
   click "Update All".  This will generate all the generated html
   (team pages, etc.).  Verify that this worked by clicking some links
   in the left nav, including some individual team pages.  If
   everything is good through this step, then that means that the site
   properly installed.  Now you're ready to customize.

6. In the data destination directory are 3 files you'll want to play
   with: league.txt contains settings for the league such as what
   types of transactions are allowed.  teams.txt lists all the teams
   with their vital info.  stat.txt is the player database.  You can
   edit these files (detailed info is in section III), and then do
   another Update to propagate those changes.  In the css directory,
   main.css is used to specify the look-and-feel of the site, so you
   can edit that to change colors, fonts, etc.

II.	In-depth explanation of installer

Coming soon

III.	In-depth explanation of web site scripts

Coming soon

IV.	Greg Greenman's license agreement

Coming soon