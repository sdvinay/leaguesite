<?php

# $Revision: 1.2 $
# $Date: 2003-04-09 17:59:19-07 $

require_once("utils.php");
require_once("teamlist.php");
require_once("playerlist.php");
require_once("filters.php");
require_once("expenselist.php");

ReadInCGI();

$num_cols = 5; // number of columns in main player/expense table

$teamnum = $CGI["teamnum"];
$tlist = new TeamList();
$teamObj = $tlist->GetTeam($teamnum);

$expenselist = new ExpenseList();
$expenselist->Generate(new SimpleFilter("teamnum", $teamnum));
$exp_total = 0;
while (list($dummy, $exp) = $expenselist->each())
{
	$exp_total += $exp->amount;
}

?>
<html><head><title><?= $teamObj->teamnum ?> <?= $teamObj->teamname ?></title>
<link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>
<body>
<center><h2>$$league_name$$</h2>
<h3><?= $teamObj->teamnum ?> <?= $teamObj->teamname ?></h3>
<hr>
<h4><a href="mailto:<?= $teamObj->email ?>"><?= $teamObj->ownername ?></a></h4>
<hr><p>
<table border=2>
<tr><th colspan=2><font size= +2>Cash</font></th></tr>
<tr><td>Salaries</td><td align=right><?= $teamObj->payrollowned ?></td></tr>
<tr><td>Bid</td><td align=right><?= $teamObj->payrollbid ?></td></tr>
<tr><td>Non-salary Expenses</td><td align=right><?= $exp_total ?></td></tr>
<tr><td>Available</td><td align=right><?= $LgOptions["salarycap"]-$teamObj->payrollowned-$teamObj->payrollbid-$exp_total ?></td></tr>
</table><br>

<table border=2>

<?
$plist = new PlayerList();
$plist->Generate(new SimpleFilter("team", $teamnum));
$i = 0;
?>
<tr><th colspan=<?=$num_cols?>><font size= +2>Players Owned</font></th></tr>
<tr><th></th><th>#</th><th>Player</th><th>Salary</th><th>Status</th></tr>
<? 
while (list($dummy, $playerObj) = $plist->each()) 
{ 
	if ($playerObj->status == 5)
	{
?>
<tr><td align=right><?= ++$i ?></td><td><?= $playerObj->playernum ?></td><td><?= $playerObj->playername ?></td><td align=right><?= $playerObj->salary ?></td><td>Sold</td></tr>
<? 
	} // if ($playerObj->status == 5)
}  // while
?>

<tr><th colspan=<?=$num_cols?>><font size= +2>Current High Bids</font></th></tr>
<tr><th></th><th>#</th><th>Player</th><th>Salary</th><th>Status</th></tr>
<? 
$plist->Reset();
while (list($dummy, $playerObj) = $plist->each()) 
{ 
	if ($playerObj->status < 5)
	{
		// TODO display status names rather than codes
?>
<tr><td align=right><?= ++$i ?></td><td><?= $playerObj->playernum ?></td><td><?= $playerObj->playername ?></td><td align=right><?= $playerObj->salary ?></td><td><?= $playerObj->status ?></td></tr>
<? 
	} // if ($playerObj->status < 5)
}  // while
?>

<?
if ($expenselist->Count() > 0)
{
	$expenselist->reset();
?>
<tr><th colspan=<?=$num_cols?>><font size= +2>Non-Player Expenses</font></th></tr>
<tr><th colspan=<?=$num_cols-1?>>Description</th><th>$</th></tr>
<?	while (list($dummy, $expenseObj) = $expenselist->each()) { ?>
<tr><td colspan=<?=$num_cols-1?>><?= $expenseObj->label ?></td><td><?= $expenseObj->amount ?></td></tr>
<?	} // while
} // if

?>

</table></center>

<hr>

</body>
</html>
