<?

# $Revision: 1.2 $
# $Date: 2003-04-02 13:41:08-08 $

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
		$this->datafile_path = "$$_data_loc$$/stat.txt";
		$this->item_class = "Player";
		$this->delimiter = ":";
		$this->format_line = "playernum:playername:status:team:salary";
	}
	
	function Generate($filter = NULL)
	{
		parent::Generate("playernum", $filter);	
	}

	// Since the format line is not stored in the file,
	// override the Init functions (leaving them empty)
	function InitRead($file) {}
	function InitWrite($file) {}

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