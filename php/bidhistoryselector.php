<? 
require("utils.php");
require("bidclass.php");

ReadInForm();
?>
<html>
<head>
</head>

<body>

<FORM name=bidfilter action="$$_php_url$$/bidhistory.php" method=GET 
target=<?=$FORM['target']?>
>
<select name="team">
<option selected value=-1>All Teams
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
	echo "<option value=$num>$name ($num)\n";
}

?></select>

<select name="player">
<option selected value=-1>All Players
<?php
$bids = file("$$_data_loc$$/bids.txt");
foreach ($bids as $bline)
{
	$bid = new Bid($bline);
	$bidplayers[$bid->pnum] = $bid->pname;
}
natcasesort($bidplayers);
reset($bidplayers);
while (list ($num, $name) = each ($bidplayers))
{
	echo "<option value=$num>$name ($num)\n";
}
?>
</select>

<input type=submit value="View">
</form>

</body>
</html>
