<?php 
# $Revision: 1.1 $
# $Date: 2003/03/01 07:34:33 $

require("utils.php"); 
ReadInCGI();

if($CGI{'dronepw'} == $LgOptions{'dronepw'})
{
	if($CGI{'leaguefileurl'})
	{
		$LgOptions{'leaguefileurl'} = $CGI{'leaguefileurl'};
		if (!isset($CGI{'isprotected'})) { /* TODO error */ }
		$LgOptions{'leaguefileprotected'} = $CGI{'isprotected'};
		WriteLeagueOptions(); // TODO error
		$optionsset = 1;
	}
} else if ($CGI{'dronepw'})
{
	$pwerror = 1;
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
<hr>
<? if ($optionsset) { ?>
<h4>The league file URL options have been set.</h4>
<p>You can review them below and edit them if necessary.</p>
<? } ?>
<form name=leaguefilelink method=post action="<?=$_SERVER{'REQUEST_URI'}?>">
<p <?= $pwerror ? "class=alert" : "" ?>>
<?= $pwerror ? "You did not enter the correct drone password. Please try again." : "Enter the drone password:" ?>
<br>
<input type=text size=12 name=dronepw>
</p>
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