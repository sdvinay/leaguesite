<?php 
# $Revision: 1.6 $
# $Date: 2003-03-14 16:58:39-08 $

require_once("utils.php"); 
require_once("bidclass.php");
require_once("bidlist.php");
require_once("filters.php");

ReadInCGI();

$team_match = ($CGI['team'] ? $CGI['team'] : -1);
$player_match = ($CGI['player'] ? $CGI['player'] : -1);

?>
<html>
<head>
  <title>Bid History</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>

<pre>

<?

$filterList = array();
if ($team_match != -1) $filterList[] = new SimpleFilter("tnum", $team_match);
if ($player_match != -1) $filterList[] = new SimpleFilter("pnum", $player_match);
$ourFilter = new AndFilter($filterList);

$bidlist = new BidList($ourFilter);

if ($bidlist->Count() == 0)
{
	print("No matching bids.\n");
}
else
{
	while(list($dummy, $bid) = $bidlist->each())
	{
		$bid->PrintBid();
	}
}
?>

</pre>

</body>
</html>