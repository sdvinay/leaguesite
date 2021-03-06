<?php 
# $Revision: 1.9 $
# $Date: 2003-05-12 15:57:24-07 $

require_once("utils.php"); 
?>

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
<title>links</title>
<link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
<base target="body">
</head>

<body class="leftnav">

<h3>$$league_name$$</h3>

<h4>General Stuff</h4>
<p>
<a href="$$_php_url$$/main.php">Main Page</a><br>
<a href="$$_static_html_url$$/constitution.html">Constitution</a><br>
<a href="$$_php_url$$/teams.php">Team Page</a><br>
<a href="$$messageboard_url$$">Message Board</a><br>
<a href="$$_static_html_url$$/raise.html">Salary Increases</a><br>

<select name="url" onChange='top.body.location=this.options[this.selectedIndex].value'>
<option value=$$_generated_html_url$$/teams.html>Teams
<?php
$teams = file("$$_data_loc$$/teams.txt");
foreach ($teams as $teamline)
{
	trim($teamline);
	$teaminfo = split(":", $teamline);
	$teamnames[$teaminfo[0]] = $teaminfo[2];
}
natcasesort ($teamnames);
reset ($teamnames);
while (list ($num, $name) = each ($teamnames))
{
	echo "<option value=$$_php_url$$/teampage.php?teamnum=$num>$name\n";
}

?></select>
</p>

<h4>Draft Stuff</h4>
<p>
<? if ($LgOptions["canresign"] != 0) { ?>
	<a href="$$_static_html_url$$/resign.html">Re-Sign Players</a><br>
<? } else { ?>
	Nontenders, sorted by<br>
	<a href="$$_data_url$$/nontenders_by_team.txt">Team</a> or <a href="$$_data_url$$/nontenders_by_salary.txt">Salary</a><br>
<? } ?>
<? if ($LgOptions["canbid"] != 0) { ?>
	<a href="$$_php_url$$/bidpage.php">Bid Page</a><br>
<? } ?>
<a href="$$_data_url$$/sold.txt">Sold Players</a><br>
<a href="$$_php_url$$/bidhistory_frameset.php">Bid History</a><br>
<a href="$$_cgi-bin_url$$/recentbids.cgi">Recent Bids</a><br>
</p>

<h4>Players</h4>
<p>
<a href="$$_generated_html_url$$/stat.html">All (alphabetical)</a><br>
<? if ($LgOptions["canbid"] != 0) { ?>
	<a href="$$_generated_html_url$$/available.html">Available (by status)</a><br>
<? } else { ?>
	<a href="$$_generated_html_url$$/available.html">Free Agents</a><br>
<? } ?>
</p>

<h4><?= $LgOptions["season"] ?> Season Info</h4>
<p>
<a href="$$_generated_html_url$$/trades.html">Trades</a><br>
<a href="$$_generated_html_url$$/claims.html">Free Agent Signings</a><br>
<a href="$$_generated_html_url$$/released.html">Releases</a><br>
<a href="$$_php_url$$/contracts.php">Long-term Contracts</a><br>
<? $LgFileURL = ($LgOptions['leaguefileprotected'] 
	? $LgOptions["leaguefileurl"] 
	: "$$_restricted_url$$/redirect_leaguefile.php" ); 
?>
<a href=<?=$LgFileURL?>>League File</a><br>
</p>

<h4>Administrative Stuff</h4>
<p>
<a href="$$_static_html_url$$/teamdata.html">Edit Team Data</a><br>
<? if ($LgOptions["cantrade"] != 0) { ?>
	<a href="$$_static_html_url$$/trade.html">Enter Trade</a><br>
<? } ?>
<? if ($LgOptions["canrelease"] != 0) { ?>
	<a href="$$_static_html_url$$/release.html">Release Player(s)</a><br>
<? } ?>
<? if ($LgOptions["cansign"] != 0) { ?>
	<a href="$$_static_html_url$$/freeagents.html">Claim Free Agent</a><br>
<? } ?>
</p>

<h4>File Drone Stuff</h4>
<p>
<a href="$$_php_url$$/drone.php">File Drone Page</a><br>
<a href="$$_php_url$$/setleaguefileurl.php">Set League File URL</a><br>
<a href="$$_static_html_url$$/filedrone.html">File Drone Procedures</a><br>
</p>

<h4>Developmental Stuff:<br>Keep Out!!!</h4>
<p>
<a href="$$_static_html_url$$/update.html">Update Page</a><br>
<a href="$$_static_html_url$$/waivers.html">Waiver Page</a><br>
</p>

</body>
</html>
