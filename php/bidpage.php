<?php 
# $Revision$
# $Date$

require("utils.php"); 
?>

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
<title>The Bid Page</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>

<h2 align="center">$$league_name$$</h2>
<h3 align="center">Bid Page</h3>

<hr>

<?
$auct_time = strtotime($LgOptions{'auctioneertime'});
if ($auct_time < time())
{
	$auct_time += 86400;
}

$time_left = $auct_time - time();
$hours_left = (int)($time_left/3600);
$minutes_left = (int)(($time_left%3600)/60);

$auct_time_pst = strftime("%I%p", $auct_time);
$auct_time_est = strftime("%I%p", $auct_time+(3*60*60));
?>

<div class="alert">Note: the auctioneer runs at <?=$auct_time_pst?> PST/<?=$auct_time_est?> 
EST.  That is approximately <?=$hours_left?> hours and <?=$minutes_left?> minutes from now.</div>

<form action="$$_cgi-bin_url$$/bidprocess.pl" method="POST">
  <input type="hidden" name="action" value="verify"><div align="center"><center><table border="2">
    <tr>
      <td>Team #</td>
      <td><input type="text" size="3" name="teamnum"></td>
      <td>Password</td>
      <td><input type="text" size="8" name="password"></td>
    </tr>
<?php
if ($HTTP_GET_VARS["pnum"])
{ 
   $pnum = $HTTP_GET_VARS["pnum"];
   $bidamt = $HTTP_GET_VARS["bid"];
?>
    <tr>
      <td>Player #</td>
      <td><input type="text" size="4" name="play0" value="<?= $pnum ?>"></td>
      <td>Bid Amount</td>
      <td><input type="text" size="3" name="bid0"" value="<?= $bidamt ?>"></td>
    </tr>
<?php
} else {
?>
    <tr>
      <td>Player #</td>
      <td><input type="text" size="4" name="play0"></td>
      <td>Bid Amount</td>
      <td><input type="text" size="3" name="bid0"></td>
    </tr>
<?php
}
?>
    <tr>
      <td>Player #</td>
      <td><input type="text" size="4" name="play1"></td>
      <td>Bid Amount</td>
      <td><input type="text" size="3" name="bid1"></td>
    </tr>
    <tr>
      <td>Player #</td>
      <td><input type="text" size="4" name="play2"></td>
      <td>Bid Amount</td>
      <td><input type="text" size="3" name="bid2"></td>
    </tr>
    <tr>
      <td>Player #</td>
      <td><input type="text" size="4" name="play3"></td>
      <td>Bid Amount</td>
      <td><input type="text" size="3" name="bid3"></td>
    </tr>
    <tr>
      <td>Player #</td>
      <td><input type="text" size="4" name="play4"></td>
      <td>Bid Amount</td>
      <td><input type="text" size="3" name="bid4"></td>
    </tr>
  </table>
  </center></div><div align="center"><center><p><input type="submit" value="Verify Bids"> <input type="reset"> </p>
  </center></div>
</form>

<hr>

</body>
</html>

