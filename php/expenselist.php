<?

# $Revision$
# $Date$

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
}

class ExpenseList extends FileBasedList
{
	function ExpenseList()
	{
		$this->datafile_path = "$$_data_loc$$/expenses.txt";
		$this->item_class = "Expense";
	}
	
	function Generate()
	{
		parent::Generate("expnum");	
	}
	
	function GenerateWithFilter($filter)
	{
		parent::GenerateWithIndexAndFilter("expnum", $filter);
	}

	function GetExpense($expnum)
	{
		return $this->myArray[$expnum];	
	}
}

?>
