<?php 
# $Revision: 1.4 $
# $Date: 2003-02-28 23:34:16-08 $

require_once("utils.php"); 
require_once("playerlist.php");
require_once("teamlist.php");
?>

<html>
<head>
  <title>Long-term Contracts</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>
<center><h2>$$league_name$$</h2>
<h3>Long-term Contracts</h3></center>
<hr><p>
<strong>Notes on contracts:</strong>
<ul>
<li>All years below refer to statistical seasons.  For instance, we're currently in <?=$LgOptions["season"]?>.
<li>"Final season" means the contract expires at the end of this season.
<li>"One more season" means one season in addition to the current season.
</ul>
<p><table border=2>
<tr><th>#</th><th>Name</th><th colspan=2>Team that Signed Contract</th><th>Year Signed</th><th colspan=2>Team that Bought Out Contract</th><th>Year Bought Out</th><th>Status</th>
<?php
#read the contracts.txt file
$lines = file("$$_data_loc$$/contracts.txt");
foreach ($lines as $contractline)
{
	trim($contractline);
	$contractaslist = split(":", $contractline);
	
	$contractage = $LgOptions["season"] - $contractaslist[2];
	if ($contractage > 2)
		$contractstatus = "Contract expired";

	//calculate the contract status	
	elseif ($contractaslist[4] > 0) // bought out
	{
		$contractstatus = "Paying waiver penalty";
	}
	elseif ($contractage == 0)
	{
		$contractstatus = "Two more seasons";
	}
	elseif ($contractage == 1)
	{
		$contractstatus = "One more season";
	}
	elseif ($contractage == 2)
	{
		$contractstatus = "Final season";
	}
?>
<tr>
<td><?=$contractaslist[0]?></td>
<td><?=GetPlayerName($contractaslist[0])?></td>
<td><?=$contractaslist[1]?></td>
<td><?=GetTeamName($contractaslist[1])?></td>
<td><?=$contractaslist[2]?></td>
<td><?=$contractaslist[3]?></td>
<td><?=GetTeamName($contractaslist[3])?></td>
<td><?=$contractaslist[4]?></td>
<td><?=$contractstatus?></td>
</tr>
<?
}
?>
</table></p>

<h3>Rules for Contracts </h3>

<p> After the draft, each team may sign zero, one or two players to a long term contract. Contracted
Players are retained for 2 years (beyond the current year) with no further salary increase. The contracted
player may be released at any time, but the owning team will be penalized the amount of
the contracted player's normal salary increase (only the increase, not the entire salary) for the
remainder of the contract.<br>
<br>
Any team which signed two players to long term contracts in the preceding
season may not sign any in the current season. </p>

<p>Once the player's contract expires (third year after signing contract), the player becomes
a free agent. His team may not retain him. </p>

</body>
</html>
