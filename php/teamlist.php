<?

# $Revision$
# $Date$

require_once("utils.php");
require_once("listbase.php");

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
	
	// order of args is consistent with teams.txt
	function SetProperties($in_teamnum, $in_password, $in_teamname, $in_ownername, $in_email, 
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

class TeamList extends FileBasedList
{
	function TeamList()
	{
		// TODO this refers to teams2.txt
		$this->datafile_path = "$$_data_loc$$/teams2.txt";
		$this->item_class = "Team";
		
		$this->Generate("teamnum");
	}

	function GetTeam($teamnum)
	{
		return $this->myArray[$teamnum];	
	}
}

function GetTeamName($teamnum)
{
	static $tlist;
	if (!isset($tlist))
	{
		$tlist = new TeamList();
	}
	
	$team = $tlist->GetTeam($teamnum);
	return $team->teamname;
}

?>