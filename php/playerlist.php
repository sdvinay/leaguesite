<?

# $Revision$
# $Date$

require_once("utils.php");
require_once("listbase.php");
require_once("filters.php");

class Player
{
	var $playernum;
	var $playername;
	var $status;
	var $team;
	var $salary;
	
    // this is the standard constructor, but it's commented out so that the PlayerList can use the
	// default constructor.  Maybe this stay around, but as a named method.
	function SetProperties($in_playernum, $in_playername, $in_status, $in_team, $in_salary)
	{
		$this->playernum = $in_playernum;
		$this->playername = $in_playername;
		$this->status = $in_status;
		$this->team = $in_team;
		$this->salary = $in_salary;
	}

}

class PlayerList extends FileBasedList
{
	function PlayerList()
	{
		// TODO this refers to stat2.txt
		$this->datafile_path = "$$_data_loc$$/stat2.txt";
		$this->item_class = "Player";
	}
	
	function Generate()
	{
		parent::Generate("playernum");	
	}
	
	function GenerateWithFilter($filter)
	{
		parent::GenerateWithIndexAndFilter("playernum", $filter);
	}

	function GetPlayer($playernum)
	{
		return $this->myArray[$playernum];	
	}
}

function GetPlayerName($playernum)
{
	static $plist;
	if (!isset($plist))
	{
		$plist = new PlayerList();
		$plist->Generate();
	}
	
	$player = $plist->GetPlayer($playernum);
	return $player->playername;
}

?>