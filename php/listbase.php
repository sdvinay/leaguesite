<?
// $Revision: 1.4 $
// $Date: 2003-04-02 13:40:50-08 $

require_once("filewriter.php");

// Generic list class, used to encapsulate a list
// Derive off of this to make more complex lists
//   (i.e., read in from file, from database, etc.)
// Owns a real array
// Implements  the standard iterator functions as methods
class ListBase
{
	var $myArray = array();
	
	function reset()	{ return reset($this->myArray); }
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
	var $format_line; // colon-delimited list of fields (read from file, 
		// used when writing back to file)
		
	function Generate($index_field_name)
	{
		$lines = @file($this->datafile_path);
		list($dummy, $format_line) = each($lines);
		$this->format_line = trim($format_line);
		$fields  = split(":", $this->format_line);
		
		while (list($dummy, $data_line) = each($lines))
		{
			trim ($data_line);
			$data_as_list = split(":", $data_line);
			$obj = new $this->item_class;
			while (list($i, $data_item) = each($data_as_list))
			{
				$field_name = $fields[$i];
				$obj->$field_name = trim($data_item);
			}
			$this->myArray[$obj->$index_field_name] = $obj;
		}
		$this->reset();
	}

	function GenerateWithIndexAndFilter($index_field_name, $filter)
	{
		$lines = @file($this->datafile_path);
		list($dummy, $format_line) = each($lines);
		$this->format_line = trim($format_line);
		$fields  = split(":", $this->format_line);
		
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
		$this->reset();
	}
	
	// iterate over list, writing each to file
	// resets the internal pointer
	function Write()
	{
		$fw = new FileWriter($this->datafile_path);
		$fw->WriteLine($this->format_line);
		$fields = split(":", $this->format_line);
		$this->reset();
		while (list($dummy, $obj) = $this->each())
		{
			$line = "";
			foreach ($fields as $field)
			{
				if (strlen($line) > 0) $line .= ":";
				$line .= ($obj->$field);
			} // iterate each field
			$fw->WriteLine($line);
		} // iterate each obj in array
		$fw->Close();
		$this->reset();
	}
	
	// returns a list of all objects in the array that match $filter
	// resets the internal pointer
	function Find($filter)
	{
		$this->reset();
		$ret = array();
		while (list($index, $obj) = $this->Each())
		{
			if ($filter->Match($obj))
				$ret[$index] = $obj;
		}
		$this->reset();
		return $ret;
	}
}

?>