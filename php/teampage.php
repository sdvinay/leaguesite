<?php

# $Revision: 1.1 $
# $Date: 2003-03-24 23:27:13-08 $

require_once("utils.php");
require_once("teamlist.php");
require_once("playerlist.php");
require_once("filters.php");
require_once("expenselist.php");

ReadInCGI();

$teamnum = $CGI["teamnum"];
$tlist = new TeamList();
$teamObj = $tlist->GetTeam($teamnum);

?>
<html><head><title><?= $teamObj->teamnum ?> <?= $teamObj->teamname ?></title>
<link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>
<body>
<center><h2>$$league_name$$</h2>
<h3><?= $teamObj->teamnum ?> <?= $teamObj->teamname ?></h3>
<hr>
<h4><a href="<?= $teamObj->email ?>"><?= $teamObj->ownername ?></a></h4>
<hr><p>
<table border=2>
<tr><th colspan=2><font size= +2>Cash</font></th></tr>
<tr><td>Spent</td><td align=right><?= $teamObj->payrollowned ?></td></tr>
<tr><td>Bid</td><td align=right><?= $teamObj->payrollbid ?></td></tr>
<tr><td>Available</td><td align=right><?= $LgOptions["salarycap"]-$teamObj->payrollowned-$teamObj->payrollbid ?></td></tr>
</table><br>

<table border=2>

<?
$soldplist = new PlayerList();
//$filterlist = list(new SimpleFilter("team", $teamnum), new SimpleFilter("status", 5));
$soldplist->GenerateWithFilter(new SimpleFilter("team", $teamnum));
$i = 0;
?>
<tr><th colspan=8><font size= +2>Players Owned</font></th></tr>
<tr><th></th><th>#</th><th>Player</th><th>Salary</th><th>Status</th></tr>
<? while (list($dummy, $playerObj) = $soldplist->each()) { ?>
<tr><td align=right><?= ++$i ?></td><td><?= $playerObj->playernum ?></td><td><?= $playerObj->playername ?></td><td align=right><?= $playerObj->salary ?></td><td>Sold</td></tr>
<? } ?>

<tr><th colspan=8><font size= +2>Current High Bids</font></th></tr>
<tr><th></th><th>#</th><th>Player</th><th>Salary</th><th>Status</th></tr>

<?
$expenselist = new ExpenseList();
$expenselist->GenerateWithFilter(new SimpleFilter("teamnum", $teamnum));

if ($expenselist->Count() > 0)
{
?>
<tr><th colspan=8><font size= +2>Non-Player Expenses</font></th></tr>
<tr><th>#</th><th colspan=6>Description</th><th>$</th></tr>
<?	while (list($dummy, $expenseObj) = $expenselist->each()) { ?>
<tr><td><?= $expenseObj->expnum ?></td><td colspan=6><?= $expenseObj->label ?></td><td><?= $expenseObj->amount ?></td></tr>
<?	} // while
} // if

?>

</table></center>

<hr>

</body>
</html>
