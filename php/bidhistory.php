<?php 
# $Revision: 1.4 $
# $Date: 2003-02-28 12:32:50-08 $

require("utils.php"); 
require("bidclass.php");
require("filters.php");

ReadInCGI();

$team_match = ($CGI['team'] ? $CGI['team'] : -1);
$player_match = ($CGI['player'] ? $CGI['player'] : -1);

$bids = file("$$_data_loc$$/bids.txt");

?>
<html>
<head>
  <title>Bid History</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>

<pre>

<?
$bidsfound = 0;

$teamFilter = ($team_match == -1) ? new Filter() : new SimpleFilter("tnum", $team_match);
$playerFilter = ($player_match == -1) ? new Filter() : new SimpleFilter("pnum", $player_match);
$ourFilter = new AndFilter($teamFilter, $playerFilter);

foreach ($bids as $bline)
{
	$bid = new Bid($bline);
	
	if ($ourFilter->Match($bid))
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