<?

# $Revision$
# $Date$

// The classes defined here are for use with the
// stat files downloaded from sportsinteractive.com

// TODO there should be a generic "stat-line" interface class
// (or two of them, for hitting and pitching) that
// classes like this inherit from.  As soon as I need
// to add any more classes like this, I should define
// those classes.

// Though the datafile uses Sports Interactive player IDs, this
// class replaces them with playernums when generating the list

require_once("utils.php");
require_once("listbase.php");
require_once("playerid_xref.php");

class si_batline
{
	// I'll let the format line define the var names
}

class si_pitchline
{
	// I'll let the format line define the var names
}


// pure virtual class used to implement some functionality
// common to both si_ clases; only the classes derived
// from si_list should ever be instantiated
class si_list extends FileBasedList
{
	var $timestamp; // the "last updated" stamp on the stats
	var $xref; // a PlayerID_XRef obj used for ID lookups

	// enforce pure virtual	
	function si_list()
	{
		if (strcasecmp(get_class($this), "si_list") == 0)
			trigger_error("trying to instantiate pure virtual class si_list");
	}

	// The format_line is the first line (it has a hash mark prepended to it)
	// The second line is the update stamp
	function InitRead($file)
	{
		$this->format_line = substr(trim($file->GetLine()),1);
		$this->timestamp = substr(trim($file->GetLine()),1);
	}
	
	// Writing is not allowed, so trigger an error in InitWrite()
	function InitWrite($fd)
	{
		trigger_error("Can not write out an si_batList");
	}
	
	// Replace the SI player id with our playernum
	function ProcessObj(&$obj)
	{
		$obj->playernum = $this->LookupID($obj->PlayerID);
		$obj->PlayerName = substr($obj->PlayerName, 1, -1);
	}
	
	
	function LookupID($id)
	{
		static $xref = NULL;
		if (is_null($xref))
		{
			$xref = new PlayerID_xref("sportsinteractive");
		}
		
		return $xref->GetID("playernum", $id);
	}
/*	
	function Generate($filter = NULL)
	{
		return parent::Generate("PlayerID", $filter);
	}*/
}

class si_batList extends si_list
{
	function si_batList()
	{
		$this->datafile_path = "$$_data_loc$$/mlb2003-batting.csv";
		$this->item_class = "si_batline";
		$this->delimiter = ",";
	}
	
	function ProcessObj(&$obj)
	{
		parent::ProcessObj(&$obj);
		$obj->BA = substr($obj->BA, 1, -1);
		$obj->OBP = substr($obj->OBP, 1, -1);
		$obj->SLG = substr($obj->SLG, 1, -1);
		$obj->OPS = substr($obj->OPS, 1, -1);
	}
}

class si_pitchList extends si_list
{
	function si_pitchList()
	{
		$this->datafile_path = "$$_data_loc$$/mlb2003-pitching.csv";
		$this->item_class = "si_pitchline";
		$this->delimiter = ",";
	}

	function ProcessObj(&$obj)
	{
		parent::ProcessObj(&$obj);
		$obj->IP = substr($obj->IP, 1, -1);
		$obj->ERA = substr($obj->ERA, 1, -1);
	}
}