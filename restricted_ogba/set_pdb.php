<?php
# $Revision$
# $Date$

require_once("$$_php_loc$$/utils.php"); 
require_once("$$_php_loc$$/expenselist.php");
require_once("$$_php_loc$$/teamlist.php");
require_once("$$_php_loc$$/pdbtable.php");
ReadInCGI();


// assume that the user is authenticated at this point
$teamnum = $_SERVER{'PHP_AUTH_USER'};
WriteAsComment($teamnum);

$bSet = false; // true if the PDBs have been set (either just now, or previously)
$bUpdated = false; // true if PDBs have been set during this request
$DomPDB = 0;
$FrnPDB = 0;

$pdbs = new PDBTable();

// if this is a form post, then update the values
if (isset($CGI["DomPDB"]))
{
	$bSet = true;
	$bUpdated = true;
	$pdbs->SetDomPDBAmt($teamnum, $CGI["DomPDB"]);
	$pdbs->SetFrnPDBAmt($teamnum, $CGI["FrnPDB"]);
}

// Even if we've updated PDBs, get them from the table,
// just to verify that the table has them right
$DomPDB = $pdbs->GetDomPDBAmt($teamnum);
$FrnPDB = $pdbs->GetFrnPDBAmt($teamnum);
if (($DomPDB !== "" ) || ($FrnPDB !== ""))
{
	$bSet = true;
}

?>

<html>
<head>
  <title>Set PDBs</title>
  <link rel="stylesheet" href="$$_css_url$$/main.css" type="text/css">
</head>

<body>
<center><h2>$$league_name$$</h2>
<h3>Set PDBs</h3>
<h3><?=GetTeamName($teamnum)?></h3></center>
<hr>

<? if ($bUpdated) { ?>
<h4>Your PDBs have been updated.</h4>
<? } ?>

<? if ($bSet) { ?>
<p>These are your current PDBs.</p>
<table border=1>
<tr><td>Domestic PDB</td><td><?=$DomPDB?></td></tr>
<tr><td>Foreign PDB</td><td><?=$FrnPDB?></td></tr>
</table border=1>
<p>If you would like to change your PDBs, edit them in the form below:</p>
<? } else { ?>
<h4>Your PDBs have not yet been set; please set them below.</h4>
<? } ?>

<form name=pdb method=post action="<?=$_SERVER{'REQUEST_URI'}?>">
<table border=1>
<tr><td>Domestic PDB</td><td><input type=text size=6 name=DomPDB value=<?=$DomPDB?>></td></tr>
<tr><td>Foreign PDB</td><td><input type=text size=6 name=FrnPDB value=<?=$FrnPDB?>></td></tr>
</table>
<p><input type=submit value="Submit"> <input type=reset></p>
</form>

</body>
</html>