<?

require_once("listbase.php");
require_once("bidclass.php");
require_once("filters.php");

class BidList extends ListBase
{
	var $datafilepath = "$$_data_loc$$/bids.txt";
	
	function BidList($filter)
	{
		$bids = file($this->datafilepath);
		foreach ($bids as $bline)
		{
			$bid = new Bid($bline);
			
			if ($filter->Match($bid))
			{
				$this->myArray[] = $bid;
			}
		}
	}

}

?>
