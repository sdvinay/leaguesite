<?php

// $Revision$
// $Date$

require_once("$$_php_loc$$/organization.php");
require_once("utils.php");
require_once("teamlist.php");

?>

<html><head><title>Team Page</title>
<link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>
<body>
<center><h2>$$league_name$$</h2>
<h3>Team Page</h3>
<hr>
<table border=2>
<?

$tmlist = new TeamList();

// TODO iterate over the tree, annotating each non-leaf node with the email
// address (which is a concatenation of all the emails from the leaf nodes
// on the branch)

foreach ($org->lgArray as $lgObj)
{
?>
	<tr><th colspan=8 height=50><a href="mailto:<?=$lgObj->email?>"><big +2><?= $lgObj->name ?></big></a></th></tr>
<?
	foreach ($lgObj->divArray as $divObj)
	{
?>
		<tr><th colspan=8><a href="mailto:<?=$divObj->email?>"><?=$divObj->name?></a></th></tr>
		<tr><th>#</th><th>Team Name</th><th>Stadium</th><th>Owner</th><th>#</th><th>Spent</th><th>Bid</th><th>Remaining</th></tr>
<?
		foreach ($divObj->teamNumArray as $teamnum)
		{
			$tmObj = $tmlist->GetTeam($teamnum);
?>		
			<tr>
				<td><?=$teamnum?></td>
				<td><a href="$$_php_url$$/teampage.php?teamnum=<?=$teamnum?>"><?=$tmObj->teamname?></a></td>
				<td><?=$tmObj->ballpark?></td>
				<td><a href="mailto:<?=$tmObj->email?>"><?=$tmObj->ownername?></a></td>
				<td align=right><?=$tmObj->plyrsowned?></td>
				<td align=right><?=$tmObj->payrollowned?></td>
				<td align=right><?=$tmObj->payrollbid?></td>
				<td align=right><?= $LgOptions["salarycap"]-$tmObj->payrollowned-$tmObj->payrollbid ?></td>
			</tr>
<?
		} // foreach ($divObj->teamNumArray as $teamnum)
	}// foreach ($lgObj->divArray as $divObj)
} // foreach ($org->lgArray as $lgObj) 
?>
</table></center>

<hr>

</body>
</html>