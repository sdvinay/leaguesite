<? 
// $Revision: 1.4 $
// $Date: 2003-03-03 00:27:52-08 $

require_once("utils.php");
require_once("bidclass.php");
require_once("bidlist.php");

ReadInCGI();
?>
<html>
<head>
  <title>Filter the Bid History</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>

<FORM name=bidfilter action="$$_php_url$$/bidhistory.php" method=GET 
target=<?=$CGI['target']?>
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
	$selected = ($CGI[team] == $num ? "selected" : "" );
	echo "<option value=$num $selected>$name ($num)\n";
}

?></select>

<select name="player">
<option value=-1>All Players
<?php
$bidlist = new BidList(new Filter());
while(list($dummy, $bid) = $bidlist->each())
{
	$bidplayers[$bid->pnum] = $bid->pname;
}
natcasesort($bidplayers);
reset($bidplayers);
while (list ($num, $name) = each ($bidplayers))
{
	$selected = ($CGI[player] == $num ? "selected" : "" );
	echo "<option value=$num $selected>$name ($num)\n";
}
?>
</select>

<input type=submit value="View">
</form>

</body>
</html>
