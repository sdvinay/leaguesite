<?php 
# $Revision$
# $Date$

require("utils.php"); 
ReadInCGI();

if($CGI{'leaguefileurl'})
{
	$LgOptions{'leaguefileurl'} = $CGI{'leaguefileurl'};
	if (!isset($CGI{'isprotected'})) { /* TODO error */ }
	$LgOptions{'leaguefileprotected'} = $CGI{'isprotected'};
	WriteLeagueOptions(); // TODO error
}
?>

<html>
<head>
  <title>League File Link</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>
<center><h2>$$league_name$$</h2>
<h3>League File Link</h3></center>
<hr><p>

<form name=leaguefilelink method=post action="<?=$_SERVER{'REQUEST_URI'}?>">
<p>
Edit the URL for the league file:<br>
<input type=text size=80 name=leaguefileurl value=<?=$LgOptions{'leaguefileurl'}?>>
</p>
<p>
Is this URL/file password-protected?
<select name=isprotected>
<option value=1 <?=($LgOptions{'leaguefileprotected'} ? "selected" : "")?>>Yes</option>
<option value=0 <?=($LgOptions{'leaguefileprotected'} ? "" : "selected")?>>No</option>
</select>
</p>
<p>
<input type=submit value="Submit">&nbsp;<input type=reset><br>
</p>
</form>

</body>
</html>