<?php

// $Revision: 1.1 $
// $Date: 2003-04-08 17:58:03-07 $

require_once("$$_php_loc$$/organization.php");
require_once("utils.php");
require_once("teamlist.php");
require_once("expenselist.php");

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

$num_cols = 9; // This is the number of columns in the main table

foreach ($org->lgArray as $lgObj)
{
?>
	<tr><th colspan=<?=$num_cols?> height=50><a href="mailto:<?=$lgObj->email?>"><big +2><?= $lgObj->name ?></big></a></th></tr>
<?
	foreach ($lgObj->divArray as $divObj)
	{
?>
		<tr><th colspan=<?=$num_cols?>><a href="mailto:<?=$divObj->email?>"><?=$divObj->name?></a></th></tr>
		<tr><th>#</th><th>Team Name</th><th>Stadium</th><th>Owner</th><th>#</th><th>Salaries</th><th>Bids</th><th>Exp</th><th>Remaining</th></tr>
<?
		foreach ($divObj->teamNumArray as $teamnum)
		{
			$tmObj = $tmlist->GetTeam($teamnum);
			
			// Total up the expenses 
			// TODO note that non-player expenses are inconsistent with salaries, in that
			//   the total is not stored in the teams data file
			$expenselist = new ExpenseList(); // TODO re-use the expenselist
			$expenselist->Generate(new SimpleFilter("teamnum", $teamnum));
			$exp_total = 0;
			while (list($dummy, $exp) = $expenselist->each())
			{
				$exp_total += $exp->amount;
			}
			
?>		
			<tr>
				<td><?=$teamnum?></td>
				<td><a href="$$_php_url$$/teampage.php?teamnum=<?=$teamnum?>"><?=$tmObj->teamname?></a></td>
				<td><?=$tmObj->ballpark?></td>
				<td><a href="mailto:<?=$tmObj->email?>"><?=$tmObj->ownername?></a></td>
				<td align=right><?=$tmObj->plyrsowned?></td>
				<td align=right><?=$tmObj->payrollowned?></td>
				<td align=right><?=$tmObj->payrollbid?></td>
				<td align=right><?=$exp_total?></td>
				<td align=right><?= $LgOptions["salarycap"]-$tmObj->payrollowned-$tmObj->payrollbid-$exp_total ?></td>
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