<?

$g_bidhistoryurl = "$$_php_url$$/bidhistory.php";

class Bid
{
	var $date;
	var $pnum;
	var $pname;
	var $tnum;
	var $tname;
	var $newbidamt;
	var $oldbidamt;
	var $bline;
	
	function Bid($in_bline)
	{
		$this->bline = trim($in_bline);
		$temp_array = preg_split("/\t+/", $this->bline);
		$this->date = $temp_array[0];
		$this->pnum = $temp_array[2];
		$this->pname = $temp_array[3];
		preg_match("/^(...)\s+(.*)$/", trim($temp_array[1]), $matches);
		$this->tnum = $matches[1];
		$this->tname = $matches[2];
		$this->newbidamt = $temp_array[4];
		$this->oldbidamt = $temp_array[5];
	}
	
	function Printbid()
	{
		global $g_bidhistoryurl;
		printf("%s\t<a href=%s?team=%s>%s %s</a>\t<a href=%s?player=%s>%s\t%s</a>\t%s\t%s\n",
			$this->date, $g_bidhistoryurl, $this->tnum, $this->tnum, $this->tname, 
			$g_bidhistoryurl, $this->pnum, $this->pnum, $this->pname, $this->newbidamt, $this->oldbidamt);
	}
	
}

?>