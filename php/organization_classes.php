<?

// $Revision$
// $Date$

// These classes define the structure of a DMB organization

// Three tiers: Organization, League, Division
// A division is a list of teams (only the team numbers are stored
//  here, the actual data on teams is in the teams data file)

require_once("utils.php");

class Organization
{
	var $name;
	var $abbr;
	var $lgArray; // array of League objects
}

class League
{
	var $name;
	var $abbr;
	var $divArray; // array of Division objects
}

class Division
{
	var $name;
	var $abbr;
	var $teamNumArray; // array of Team Num objects
}


?>

