<?php 
# $Revision$
# $Date$

require("utils.php"); 

$team_match = ($_POST['team'] ? $_POST['team'] : $_GET['team']);
$player_match = ($_POST['player'] ? $_POST['player'] : $_GET['player']);

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
		$match = ($team_match ? ($team_match == $this->tnum) : 1);
		return $match;
	}

	function MatchPlayer()
	{
		global $player_match;
		$match = ($player_match ? ($player_match == $this->pnum) : 1);
		return $match;
	}
	
	function Match()
	{
		$x = $this->MatchTeam();
		return ( $x && $this->MatchPlayer());
	}
}

$bids = file("$$_data_loc$$/bids.txt");

?>

<html>
<head>
</head>

<body>

<pre>

<?
foreach ($bids as $bline)
{
	$bid = new Bid($bline);
	if ($bid->Match())
	{
		$bid->Printbid();
	}
}
?>

</pre>

</body>
</html>