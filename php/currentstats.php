<?php

# $Revision$
# $Date$

require_once("utils.php");
require_once("teamlist.php");
require_once("playerlist.php");
require_once("filters.php");
require_once("sportsinteractive.php");
require_once("profiler.php");

ReadInCGI();

// The teamnum parameter indicates the team number, or is 999
// for FAs
$teamnum = $CGI["teamnum"];

$profiler = new Profiler("new PlayerList()");
$plist = new PlayerList();
$profiler->Phase("plist->Generate()");
$plist->Generate(new SimpleFilter("team", $teamnum));
$profiler->Phase("create filter");
$filter = $plist->CreateFilter();

$profiler->Phase("new batlist");
$batlist = new si_batList();
$profiler->Phase("batlist->Generate()");
$batlist->Generate("PlayerID", $filter);

$profiler->Phase("new pitchlist");
$pitchlist = new si_pitchList();
$profiler->Phase("pitchlist->Generate");
$pitchlist->Generate("PlayerID", $filter);
$profiler->Phase("print header");

?>
<html>
<head>
<title>Team Tracker</title>
    <link rel="stylesheet" href="http://sam.doorstop.net/~vinay/style/main.css" type="text/css" />
    <link rel="stylesheet" href="http://sam.doorstop.net/~vinay/teamtracker/teamtracker.css" type="text/css" />
</head>

<body>

<h3><?= ($teamnum == 999 ? "Free Agents" : GetTeamName($teamnum)) ?></h3>

<? // Do batters ?>

<h4>Batters</h4>
<div class=listings><table>
<col align=left width=20>
<col align=left width=110>
<col align=left width=20>
<col span=14 align=right width=20>
<tr>
<th align=center>#</th>
<th align=left>Name</th>
<th align=right>G</th>
<th align=right>AB</th>
<th align=right>R</th>
<th align=right>H</th>
<th align=right>2B</th>
<th align=right>3B</th>
<th align=right>HR</th>
<th align=right>RBI</th>
<th align=right>BB</th>
<th align=right>SO</th>
<th align=right>SB</th>
<th align=right>CS</th>
<th align=right>BA</th>
<th align=right>OBP</th>
<th align=right>SLG</th>
<?
function ExpressLikeBA($avg)
{
	$str = sprintf("%01.3f", $avg);
	if (substr($str,0,1) == 0) $str = substr($str,1);
	return $str;
}

$profiler->Phase("print batters");
$row = 0;
while (list($id, $batline) = $batlist->each())
{
	print(($row%2?"<tr class=oddrow>":"<tr class=evenrow>"));
	print("<td align=center>" . $batline->playernum . "</td>");
	print("<td align=left>" . $batline->PlayerName . "</td>");
	print("<td align=right>" . $batline->GP . "</td>");
	print("<td align=right>" . $batline->AB . "</td>");
	print("<td align=right>" . $batline->R . "</td>");
	print("<td align=right>" . $batline->H . "</td>");
	print("<td align=right>" . $batline->B2 . "</td>");
	print("<td align=right>" . $batline->B3 . "</td>");
	print("<td align=right>" . $batline->HR . "</td>");
	print("<td align=right>" . $batline->RBI . "</td>");
	print("<td align=right>" . $batline->BB . "</td>");
	print("<td align=right>" . $batline->SO . "</td>");
	print("<td align=right>" . $batline->SB . "</td>");
	print("<td align=right>" . $batline->CS . "</td>");
	print("<td align=right>" . ExpressLikeBA($batline->BA) . "</td>");
	print("<td align=right>" . ExpressLikeBA($batline->OBP) . "</td>");
	print("<td align=right>" . ExpressLikeBA($batline->SLG) . "</td>");
	print("</tr>\n");
	$row++;
}
?>

</table>
</div>

<? // Do pitchers ?>

<h4>Pitchers</h4>
<div class=listings>
<table>
<col align=center width=20>
<col align=left width=110>
<col span=14 align=right width=20>
<tr>
<th align=center>#</th>
<th align=left>Name</th>
<th align=right>G</th>
<th align=right>GS</th>
<th align=right>IP</th>
<th align=right>H</th>
<th align=right>R</th>
<th align=right>ER</th>
<th align=right>HR</th>
<th align=right>BB</th>
<th align=right>SO</th>
<th align=right>ERA</th>
<th align=right>W</th>
<th align=right>L</th>
<th align=right>Sv</th>
<th align=right>CG</th>
<?
$profiler->Phase("print pitchers");
$row = 0;
while (list($id, $pitchline) = $pitchlist->each())
{
	print(($row%2?"<tr class=oddrow>":"<tr class=evenrow>"));
	print("<td align=center>" . $pitchline->playernum . "</td>");
	print("<td align=left>" . $pitchline->PlayerName . "</td>");
	print("<td align=right>" . $pitchline->GP . "</td>");
	print("<td align=right>" . $pitchline->GS . "</td>");
	print("<td align=right>" . sprintf("%01.1f", $pitchline->IP) . "</td>");
	print("<td align=right>" . $pitchline->H . "</td>");
	print("<td align=right>" . $pitchline->R . "</td>");
	print("<td align=right>" . $pitchline->ER . "</td>");
	print("<td align=right>" . $pitchline->HR . "</td>");
	print("<td align=right>" . $pitchline->BB . "</td>");
	print("<td align=right>" . $pitchline->SO . "</td>");
	print("<td align=right>" . sprintf("%01.2f", $pitchline->ERA) . "</td>");
	print("<td align=right>" . $pitchline->W . "</td>");
	print("<td align=right>" . $pitchline->L . "</td>");
	print("<td align=right>" . $pitchline->SV . "</td>");
	print("<td align=right>" . $pitchline->CG . "</td>");
	print("</tr>\n");
	$row++;
}
print "</table>\n";

$profiler->PrintTimesHTML();

?>

<p>Stats courtesy of <a href=http://www.SportsInteractive.com>http://www.SportsInteractive.com</a>
<? if ($batlist->timestamp) { printf("(%s)", $batlist->timestamp); } ?>
</p>
</body>
</html>
