<?

class Bid
{
	var $date;
	var $pnum;
	var $pname;
	var $tnum;
	var $tname;
	var $newbidamt;
	var $oldbidamt;
	var $bline;
	
	function Bid($in_bline)
	{
		$this->bline = trim($in_bline);
		$temp_array = preg_split("/\t+/", $this->bline);
		$this->date = $temp_array[0];
		$this->pnum = $temp_array[2];
		$this->pname = $temp_array[3];
		list($this->tnum, $this->tname) = preg_split("/\s+/",$temp_array[1]);
		$this->newbidamt = $temp_array[4];
		$this->oldbidamt = $temp_array[5];
	}
	
	function Printbid()
	{
		print "$this->bline\n";
	}
	
	function MatchTeam()
	{
		global $team_match;
		$match = ($team_match == -1) || ($team_match == $this->tnum);
		return $match;
	}

	function MatchPlayer()
	{
		global $player_match;
		$match = ($player_match == -1) || ($player_match == $this->pnum);
		return $match;
	}
	
	function Match()
	{
		$x = $this->MatchTeam();
		return ( $x && $this->MatchPlayer());
	}
}

?>