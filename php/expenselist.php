<?

# $Revision: 1.1 $
# $Date: 2003-04-02 13:40:25-08 $

require_once("utils.php");
require_once("listbase.php");
require_once("filters.php");

class Expense
{
	var $expnum;
	var $teamnum;
	var $year;
	var $type;
	var $amount;
	var $label;
	
	function Populate($expnum, $teamnum, $year, $type, $amount, $label)
	{
		$this->expnum = $expnum;
		$this->teamnum = $teamnum;
		$this->year = $year;
		$this->type = $type;
		$this->amount = $amount;
		$this->label = $label;
	}
}

class ExpenseList extends FileBasedList
{
	var $maxnum;
	
	function ExpenseList()
	{
		$this->datafile_path = "$$_data_loc$$/expenses.txt";
		$this->item_class = "Expense";
	}
	
	function Generate()
	{
		parent::Generate("expnum");	
		list($this->maxnum, $dummy) = $this->end();
		$this->reset();
	}
	
	function GenerateWithFilter($filter)
	{
		parent::GenerateWithIndexAndFilter("expnum", $filter);
		list($this->maxnum, $dummy) = $this->end();
		$this->reset();
	}

	function GetExpense($expnum)
	{
		return $this->myArray[$expnum];	
	}
	
	// returns the Expnum one greater than the current max
	function GetNewExpnum()
	{
		return ++$this->maxnum;
	}
}

?>