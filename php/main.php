<?php 
require("utils.php"); 
RecordUserAgent();
?>

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
<title>Main Page</title>

</head>

<body>

<h2 align="center">$$league_name$$</h2>

<h3 align="center">Main Page</h3>

<hr>


<p>Welcome to the new Three Run Homer League Web Site!</p>



<p align="left">Formed in 1996, The Three Run Homer League consists of twenty four teams
divided into two leagues. The league is run with version 8.0 of <a href="http://www.diamond-mind.com/">Diamond Mind Baseball</a>.</p>

<p>Manager positions become available periodically. If you are interested in joining the
league, please send an e-mail to our commissioner, <a href="mailto:commish@trhl.doorstop.net">John Cooper</a>.</p>

<p>All managers must commit to playing their games for a full season. Further, they must
own a legal copy of DMB version 8.0 and the season being played.</p>

<div align="center">
  <center>
  <table border="1">
    <tr>
      <td align="center">
        Current Series: #<?= $LgOptions["series"] ?>
      </td>
    </tr>
    <tr>
      <td align="center">
        Deadline: <?= $LgOptions["duedate"] ?>
      </td>
    </tr>
    <tr>
      <td align="center">
        Current Server Time: <?= strftime("%I:%M:%S%p %Z", time()) ?>
      </td>
    </tr>
  </table>
  </center>
</div>

<hr>

</body>
</html>

