<?

# $Revision: 1.3 $
# $Date: 2003-04-09 17:59:02-07 $

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
	
	// Returns a filter which will match any player obj
	// that is in this PlayerList (actually, it will
	// match any obj which has a playernum that matches any
	// player in this list).  If $this changes, the filter
	// will NOT automatically update with it.
	// resets the internal pointer
	function CreateFilter()
	{
		$pnumlist = array();
		$this->reset();
		while(list($dummy, $playerObj) = $this->each())
		{
			$pnumlist[] = $playerObj->playernum;
		}
		return (new PlayerListFilter($pnumlist));
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

// Constructed with a list of playernums, this filter
// will match any obj which has a playernum in pnumlist
// Intended to be constructed by PlayerList::CreateFilter()
class PlayerListFilter extends Filter
{
	var $pnumlist;
	function PlayerListFilter($pnumlist)
	{
		$this->pnumlist = $pnumlist;
	}
	function Match($playerObj)
	{
		return (array_search($playerObj->playernum, $this->pnumlist));
	}
}

?>