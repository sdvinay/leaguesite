<?
$teamnum = $_SERVER{'PHP_AUTH_USER'};
$passwd = $_SERVER{'PHP_AUTH_PW'};

$url = "$$_cgi-bin_url$$/bidprocess.pl?teamnum=" . $teamnum . "&password=" . $passwd;

foreach ($_POST as $key => $value)
{
	if ($value)
	{
		$url .= "&$key=$value";
	}
}

foreach ($_GET as $key => $value)
{
	if ($value)
	{
		$url .= "&$key=$value";
	}
}

header("Location: $url");

?>
