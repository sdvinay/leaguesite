<?

// playerid_xref.php

// $Revision$
// $Date$

// PlayerID_xref is a list class used to cross-ref different player IDs


class PlayerID_xref extends FileBasedList
{
	var $idx;
	function PlayerID_xref($idx)
	{
		$this->idx = $idx;
		$this->datafile_path="$$_data_loc$$/playerid_xref.csv";
		$this->delimiter=",";
		$this->Generate($idx);
	}
	
	// returns -1 if not found
	function GetID($type, $in_ID)
	{
		if ($this->myArray[$in_ID] && $this->myArray[$in_ID]->$type)
			return $this->myArray[$in_ID]->$type;
		else return -1;
	}
}

?>