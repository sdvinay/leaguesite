<?
 // bidhistory_frameset.php
 //   displays two frames, the selector and the bid history
 //   if there is a query string, use that as the initial state of the history
 //   if no query string, then don't display a history
 // $Revision$
 // $Date$
require("utils.php");

$selectorurl = "$$_php_url$$/bidhistoryselector.php?target=biddisplay&" . $_SERVER['QUERY_STRING'];
$displayurl = $_SERVER['QUERY_STRING'] ?   ("$$_php_url$$/bidhistory.php?" . $_SERVER['QUERY_STRING'] ) : "" ;
?>

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; iso-8859-1">
<title>$$league_name$$</title>
</head>

<frameset rows="25,*">
  <frame src="<?= $selectorurl ?>" name="selector" marginwidth="1" marginheight="1">
  <frame src="<?= $displayurl ?>" name="biddisplay" marginwidth="1" marginheight="1">
</frameset>
</html>
