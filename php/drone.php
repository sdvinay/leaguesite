<?php

# $Revision: 1.2 $
# $Date: 2003-02-25 23:36:13-08 $

require_once("utils.php");

$series = $LgOptions["series"] + 1;
$duedate = $LgOptions["duedate"];
$duetime = $LgOptions["duetime"];
$duetimezone = $LgOptions["duetimezone"];

$timeArray = array("7pm" => "7pm", "8pm" => "8pm");
$TZArray = array("PT" => "PT", "ET" => "ET");

?>
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
  <title>File Drone Page</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>
<body>
<h2 align="center">$$league_name$$</h2>
<h3 align="center">File Drone Page</h3>
<hr>
<form action="$$_cgi-bin_url$$/drone_on.pl" method="post"> <input
 type="hidden" name="action" value="droneon">
  <div align="center">
  <center>
  <table border="1">
    <tbody>
      <tr>
        <td width="50%">New Series #</td>
        <td width="50%"><input type="text" name="SeriesNum" size="2" value="<?= $series ?>"> 
          (the series number has already been incremented)
        </td>
      </tr>
      <tr>
        <td width="50%">Deadline</td>
        <td width="50%">
           <input type="text" name="Date" size="14" value="<?= $duedate ?>">
           <? PrintDropdown("Time", $timeArray, $duetime, 3); ?>
           <? PrintDropdown("TZ", $TZArray, $duetimezone, 3); ?>
        </td>
      </tr>
      <tr>
        <td width="50%">Password</td>
        <td width="50%"><input type="text" name="DronePassword"
 size="16"></td>
      </tr>
    </tbody>
  </table>
  </center>
  </div>
  <div align="center">
  <center>
  <p>&nbsp; </p>
  </center>
  </div>
  <div align="center">
  <center>
  <p><input type="submit" value="Update Series Info"><!--webbot bot="HTMLMarkup" startspan --></p>
  </center>
<!--webbot bot="HTMLMarkup" endspan --> </div>
</form>
<hr>
<p>Please enter the series number using two digits. </p>
<p>Please format the deadline like this: "Friday May 18, 10 PM
Central". </p>
<hr>
</body>
</html>
