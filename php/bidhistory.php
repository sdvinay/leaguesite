<?php 
# $Revision: 1.1 $
# $Date: 2003/02/27 02:51:40 $

require("utils.php"); 
require("bidclass.php"); 

ReadInForm();

$team_match = ($FORM['team'] ? $FORM['team'] : -1);
$player_match = ($FORM['player'] ? $FORM['player'] : -1);

$bids = file("$$_data_loc$$/bids.txt");

?>

<html>
<head>
</head>

<body>

<pre>

<?
$bidsfound = 0;
foreach ($bids as $bline)
{
	$bid = new Bid($bline);
	if ($bid->Match())
	{
		++$bidsfound;
		$bid->Printbid();
	}
}

if ($bidsfound == 0)
{
	print("No matching bids.\n");
}
?>

</pre>

</body>
</html>