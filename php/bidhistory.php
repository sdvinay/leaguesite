<?php 
# $Revision: 1.3 $
# $Date: 2003/02/27 23:11:12 $

require("utils.php"); 
require("bidclass.php"); 

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