use strict;
use File::Copy;


my $manifest_filename = "manifest.txt";
my $installlog_filename = "install_log.txt";
my $config_filename = "config.txt";

my $manifest_filename_prefix = "manifest";
my $installlog_filename_prefix = "install_log";
my $config_filename_prefix = "config";

my $config_name; # read from argv; this determines which manifest/config files to use, etc.

# for output
my $indent_level = 0;
my $verbose = 1;

#config keys starting with '_' are reserved for internal use
my %config_vars;

#from the manifest
my %loc;
my %url;
my %instructions;


&main;

sub main
{
	if (scalar(@ARGV) > 0) 
	{ 
		$config_name = $ARGV[0]; 
		$manifest_filename = $manifest_filename_prefix . "_" . $config_name . ".txt";
		$config_filename =  $config_filename_prefix . "_" . $config_name . ".txt";
		$installlog_filename =  $installlog_filename_prefix . "_" . $config_name . ".txt";
	}

	&readconfigvars;
	
	# need to read the manifest in completely before starting the install,
	# so that it's entirely loaded into @config_vars
	open(MANIFEST, $manifest_filename)  || die ("Could not open manifest file $manifest_filename");
	while (<MANIFEST>)
	{
		my $virtual;
		my $loc;
		my $url;
		my $instructions;
		chop;
		($virtual, $loc, $url, $instructions) = split(/\s+/);
		$loc{$virtual} = $loc;
		$url{$virtual} = $url;
		$instructions{$virtual} = $instructions;
		$config_vars{"_" . $virtual . "_loc"} = $loc;
		$config_vars{"_" . $virtual . "_url"} = $url;
	}
	close (MANIFEST) || die ("file close failed");
	
	if ($verbose) { &printconfigvars };
	
	#TODO get logging to work properly
#	open(LOGFILE, "> $installlog_filename")   || die ("Could not open log file $installlog_filename for writing");
	open(LOGFILE, ">/dev/null");
	
	my $virtual;
	foreach $virtual (keys(%loc))
	{
		my $loc = $loc{$virtual};
		installdir($virtual, $loc) || die ("installation of directory $virtual to $loc failed");
	}
	close (LOGFILE) || die ("file close failed");
}


# print out the config vars
sub printconfigvars
{
	output("*** Config variables:");
	$indent_level++;
	my $key;
	foreach $key (sort(keys(%config_vars)))
	{
		&output($key . " = " . $config_vars{$key});
	}
	$indent_level--;
	return 1;
}

#first arg is directory to create
sub passive_mkdir
{
	my $dir = shift(@_);
	my @dir = split(/\//, $dir);
	my $upperdir = shift(@dir); 
	while (1) {
		($upperdir eq "") || (-e $upperdir) || mkdir($upperdir) || die ("could not create directory $upperdir");
		last if ($upperdir eq $dir);
		$upperdir = $upperdir . "/" . shift(@dir);
	}
	(-d $dir) || die ("$dir already exists but is not a directory.");
	return 1;
}

#first arg is source directory
#second arg is dest directory
sub installdir
{
	my $srcdir = shift(@_);
	my $destdir = shift(@_);
	
	output("*** Installing directory $srcdir => $destdir");
	$indent_level++;

	my $dirperms = 0;
	if ($instructions{$srcdir})
	{
		my $instr;
		foreach $instr (split(/,/, $instructions{$srcdir}))
		{
			output("$instr");
			if ($instr =~ /^DIRPERM(.*)/)
			{
				$dirperms = oct($1);
			}
		}
	}

	passive_mkdir($destdir) || die ("passive_mkdir($destdir) failed");
	if ($dirperms) { chmod($dirperms, $destdir); }

	opendir(SRCDIR, $srcdir) || die ("Failed to open directory $srcdir");
	(my @files = readdir(SRCDIR)) || die ("Failed to read directory $srcdir");
	closedir(SRCDIR) || die ("Failed to close directory $srcdir");
	my $file;
	foreach $file (@files)
	{
		my $srcpath = $srcdir . "/" . $file;
		my $destpath = $destdir . "/" . $file;
		if (-f $srcpath)
		{
			&installfile ($srcpath, $destpath, $instructions{$srcdir}) || die("Failed to install form $srcpath to $destpath");
		}
	}
	$indent_level--;
	return 1;
}

# first arg is source path
# second arg is dest path
# assumes that LOGFILE is handle for logfile
# assumes that config vars are in @config_vars
sub installfile
{
	my $srcpath = shift(@_);
	my $destpath = shift(@_);
	my $instructions = shift(@_);
	output("*** Installing file $srcpath => $destpath");
	
	my $clobber = 1;
	my $subst = 1;
	my $perms = 0;
	
	$indent_level++;
	if (-f $srcpath)
	{
		my $instr;
		if ($instructions)
		{
			foreach $instr (split(/,/, $instructions))
			{
				output("instr: $instr");
				if ($instr eq "NOCLOBBER")
				{
					$clobber = 0;
				} elsif ($instr eq "NOSUBST")
				{
					$subst = 0;
				} elsif ($instr =~ /^FILEPERM(.*)/)
				{
					$perms = oct($1);
				}
			}
		}
		
		if ($clobber || !(-e $destpath))
		{
			open(SRC, "$srcpath");
			open(DEST, ">$destpath");
			$indent_level++;
			while(<SRC>)
			{
				if ($subst && s/\$\$([^\$]*)\$\$/$config_vars{$1}/g) { output("var subst: $1=>$config_vars{$1}"); }
				print DEST $_;
			}
			if ($perms) { chmod($perms, $destpath); }
			$indent_level--;
			close(SRC) || die ("failed to close source file");
			close(DEST) || die ("failed to close dest file");
		}
		
	}
	$indent_level--;
	return 1;
}

# assumes that config vars should go in @config_vars
# assumes that vars should be read from file $config_filename
# file format:
	# key = value
	# whitespace at beginning and end of key or value is stripped
	# lines beginning with a pound sign (#) are comments
	# '=' may not appear in the key
	# keys starting with character '_' are ignored, because those are reserved
sub readconfigvars
{
	open(CONFIG, $config_filename) || die ("could not open $config_filename");
	while(<CONFIG>)
	{
		chop;
		if (($_ !~ "^#") && ($_ =~ /\s*([^=]*)\s*=\s*(.*)\s*/))
		{
			$config_vars{$1} = $2 unless ($1 =~ /^_/); #ignore reserved keys
		}
	}
	close(CONFIG) || die ("could not close config file");
}

sub output
{
	if ($verbose)
	{
		for (my $i = 0; $i < $indent_level; $i++)
		{
			print "  ";
		}
		print $_[0];
		print "\n";
	}
}