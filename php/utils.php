<?php

# $Revision: 1.7 $
# $Date: 2003-03-24 23:27:20-08 $

// Initialization stuff
session_start();
umask(0000);

$teamlist; // don't pre-populate this, it will be populated on first use
$LgOptions;

#read the league.txt file
function ReadLeagueOptions()
{
	global $LgOptions;
	$lines = file("$$_data_loc$$/league.txt");
	foreach ($lines as $optionline)
	{
		trim($optionline);
		if (preg_match("/\s*([^~]+)~(.*)/", $optionline, $matches))
		{
			$LgOptions[$matches[1]] = $matches[2];
		}
	}
}
ReadLeagueOptions();

function WriteLeagueOptions()
{
	global $LgOptions;
	$fh = fopen("$$_data_loc$$/league.txt", "w"); // TODO error
	foreach  ($LgOptions as $key => $value)
	{
		fwrite($fh, "$key~$value\n"); // TODO error
	}
	fclose($fh);
}

function RecordUserAgent()
{
	if (!isset($_SESSION['UserAgentRecorded'])
		|| !($_SESSION['UserAgentRecorded'])) 
	{
		$_SESSION['UserAgentRecorded'] = 1;
		
		$datafile="$$_data_loc$$/browsers.txt";
		if ($fd = fopen($datafile, "a"))
		{
			fwrite($fd, $_SERVER["HTTP_USER_AGENT"]);
			fwrite($fd, "\n");
			fclose($fd);
		}
	}	
}

function ReadInCGI()
{
	global $CGI;
	foreach ($_GET as $key => $value)
	{
		$CGI{$key} = $value;
	}
	
	foreach ($_POST as $key => $value)
	{
		$CGI{$key} = $value;
	}
}

function WriteAsComment($str)
{
	print("<!-- \n");
	print($str);
	print("\n --> \n");
}


?>
