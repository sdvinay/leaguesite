<?php require("utils.php"); ?>

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
