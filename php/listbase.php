<?
// $Revision: 1.3 $
// $Date: 2003-03-24 23:41:44-08 $

// Generic list class, used to encapsulate a list
// Derive off of this to make more complex lists
//   (i.e., read in from file, from database, etc.)
// Owns a real array
// Implements  the standard iterator functions as methods
class ListBase
{
	var $myArray = array();
	
	function current()	{ return current($this->myArray); }
	function each()		{ return each($this->myArray); }
	function next()		{ return next($this->myArray); }
	function prev()		{ return prev($this->myArray); }
	function end()		{ return end($this->myArray); }
	function key()		{ return key($this->myArray); }
	
	function Count()	{ return count($this->myArray); }
}

class FileBasedList extends ListBase
{
	var $datafile_path; // should be set by derived class
	var $item_class; // name of class in list; should be set by derived class
	
	function Generate($index_field_name)
	{
		$lines = @file($this->datafile_path);
		list($dummy, $format_line) = each($lines);
		$fields  = split(":", trim($format_line));
		
		while (list($dummy, $data_line) = each($lines))
		{
			trim ($data_line);
			$data_as_list = split(":", $data_line);
			$obj = new $this->item_class;
			while (list($i, $data_item) = each($data_as_list))
			{
				$field_name = $fields[$i];
				$obj->$field_name = $data_item;
			}
			$this->myArray[$obj->$index_field_name] = $obj;
		}
	}

	function GenerateWithIndexAndFilter($index_field_name, $filter)
	{
		$lines = @file($this->datafile_path);
		list($dummy, $format_line) = each($lines);
		$fields  = split(":", trim($format_line));
		
		while (list($dummy, $data_line) = each($lines))
		{
			trim ($data_line);
			$data_as_list = split(":", $data_line);
			$obj = new $this->item_class;
			while (list($i, $data_item) = each($data_as_list))
			{
				$field_name = $fields[$i];
				$obj->$field_name = $data_item;
			}
			if ($filter->Match($obj))
				$this->myArray[$obj->$index_field_name] = $obj;
		}
	}
}

?>