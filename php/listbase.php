<?

// $Revision: 1.5 $
// $Date: 2003-04-08 17:57:19-07 $

require_once("filereader.php");
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

// This class is a dummy defined for lists that don't need
// specific classes for the list items
class BasicListItem {}

class FileBasedList extends ListBase
{
	
	var $datafile_path; // should be set by derived class
	var $item_class = "BasicListItem"; // name of class in list; derived class can override
	var $format_line; // list of fields (used to read and write from file)
	var $delimiter = ":"; // string
		
	// $datafile_path should be set before call to Generate
	// The filter is optional; a null filter (which matches everything)
	//   is used if none is specified
	// Derived class may overwrite InitRead() and EndRead()
	function Generate($index_field_name, $filter = NULL)
	{
		$file = new FileReader($this->datafile_path);
		$this->InitRead($file);
		// $format_line, $delimiter $item_class must be set by Initialize()
		$fields = split($this->delimiter, $this->format_line);
// TODO		if (array_search($index_field_name, $fields) === false)
//			trigger_error("Index field specified is not a field in the data file");
		
		while ($data_line = trim($file->GetLine()))
		{
			$data_as_list = split($this->delimiter, $data_line);
			$obj = new $this->item_class;
			while ( (list($i, $data_item) = each($data_as_list)) &&
					($i < count($data_as_list)) )
			{
				$field_name = $fields[$i];
				$obj->$field_name = trim($data_item);
			}
			$this->ProcessObj(&$obj);
			if (is_null($filter) || $filter->Match($obj))
				$this->myArray[$obj->$index_field_name] = $obj;
		}
		$this->EndRead($file);
		$file->Close();
		$this->reset();
	}
	
	// Assume that format line is the first line
	// This can be overridden for any file format that is different
	//  (i.e., no format line, or comma-separated, etc.)
	function InitRead($file)
	{
		$this->format_line = trim($file->GetLine());
	}
	
	// Clean up after reading
	function EndRead()
	{
	}
	
	// Do any processing on the obj (calculated values, formatting, etc)
	function ProcessObj($obj)
	{
	}
	
	// Iterate over list, writing each to file
	// Resets the internal pointer
	// Derived class may override InitWrite() and EndWrite()
	function Write()
	{
		$fw = new FileWriter($this->datafile_path);
		$this->InitWrite($fw);

		$fields = split($this->delimiter, $this->format_line);
		$this->reset();
		while (list($dummy, $obj) = $this->each())
		{
			$line = "";
			foreach ($fields as $field)
			{
				if (strlen($line) > 0) $line .= $this->delimiter;
				$line .= ($obj->$field);
			} // iterate each field
			$fw->WriteLine($line);
		} // iterate each obj in array

		$this->EndWrite();
		$fw->Close();
		$this->reset();
	}
	
	// Assume that format_line should be written as first line
	//  of file
	// Should be overridden by derived classes that don't store 
	//  format line in first line of file
	function InitWrite($fw)
	{
		$fw->WriteLine($this->format_line);
	}
	
	// Override if any cleanup is needed
	function EndWrite($fw)
	{
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