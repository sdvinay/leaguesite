<?php

# $Revision: 1.5 $
# $Date: 2003/02/28 20:33:10 $

// Initialization stuff
session_start();
umask(0000);

$teamlist; // don't pre-populate this, it will be populated on first use
$playerlist; // ditto
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

class Team
{
	var $teamnum;
	var $teamname;
	var $password;
	var $ownername;
	var $email;
	var $ballpark;
	var $plyrsowned;
	var $plyrsbid;
	var $payrollowned;
	var $payrollbid;
	// will add more as needed
	
	// order of args to ctor is consistent with teams.txt
	function Team($in_teamnum, $in_password, $in_teamname, $in_ownername, $in_email, 
		$in_ballpark, $in_plyrsowned, $in_plyrsbid, $in_payrollowned, $in_payrollbid)
	{
		$this->teamnum = $in_teamnum;
		$this->teamname = $in_teamname;
		$this->password = $in_password;
		$this->ownername = $in_ownername;
		$this->email = $in_email;
		$this->ballpark = $in_ballpark;
		$this->plyrsowned = $in_plyrsowned;
		$this->plyrsbid = $in_plyrsbid;
		$this->payrollowned = $in_payrollowned;
		$this->payrollbid = $in_payrollbid;
	}
}

class Player
{
	var $playernum;
	var $playername;
	var $status;
	var $team;
	var $salary;
	
	function Player($in_playernum, $in_playername, $in_status, $in_team, $in_salary)
	{
		$this->playernum = $in_playernum;
		$this->playername = $in_playername;
		$this->status = $in_status;
		$this->team = $in_team;
		$this->salary = $in_salary;
	}
}

function ReadInTeamList()
{
	global $teamlist;
	$lines = file("$$_data_loc$$/teams.txt");
	foreach ($lines as $teamline)
	{
		trim ($teamline);
		$teamaslist = split(":", $teamline);
		$this_team = new Team($teamaslist[0],$teamaslist[1],$teamaslist[2],$teamaslist[3],
			$teamaslist[4],$teamaslist[5],$teamaslist[6],$teamaslist[7],$teamaslist[8],$teamaslist[9]);
		$teamlist[$this_team->teamnum] = $this_team;
	}
}

function ReadInPlayerList()
{
	global $playerlist;
	$lines = file("$$_data_loc$$/stat.txt");
	foreach ($lines as $playerline)
	{
		trim ($playerline);
		$playeraslist = split(":", $playerline);
		$this_player = new Player($playeraslist[0],$playeraslist[1],$playeraslist[2],$playeraslist[3],$playeraslist[4]);
		if ($this_player->status < 9)
			$playerlist[$this_player->playernum] = $this_player;
	}
}

function GetTeamName($teamnum)
{
	global $teamlist;
	if (!($teamlist))
		ReadInTeamList();
	return $teamlist[$teamnum]->teamname;
}

function GetPlayerName($playernum)
{
	global $playerlist;
	if (!($playerlist))
		ReadInPlayerList();
	return $playerlist[$playernum]->playername;
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


?>
